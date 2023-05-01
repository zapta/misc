from __future__ import annotations

import asyncio
import serial_asyncio
import logging
import time

from enum import Enum
# from typing import Callable, Optional, TypeVar, Iterable, Tuple
# from asyncio.protocols import BaseProtocol
from asyncio.transports import BaseTransport
from packet_encoder import PacketEncoder
from packet_decoder import PacketDecoder

# import packet_utils


# logger = logging.getLogger(__name__)
logger = logging.getLogger("client")
logging.basicConfig(level=logging.INFO)

#https://github.com/pyserial/pyserial-asyncio


class Status(Enum):
    OK = 1
    InternalError = 2
    TimeoutError = 3


class TxContext:

    def __init__(self, seq: int, endpoint: int):
        assert (endpoint > 0 and endpoint < 0xffff)
        self.__seq = seq
        self.__endpoint = endpoint
        self.__time = time.time()

    def __str__(self):
        return f"{self.__seq}->{self.__endpoint}"


class RxContext:
    pass


class BaseClientCallbacks:

    # Caller and callee.
    def on_open(self, client: SerialMessagingClient) -> None:
        print("on_connect()")

    # Caller and callee.
    def on_close(self, client: SerialMessagingClient) -> None:
        print("on_disconnect()")

    # Caller only.
    def on_response(self, client: SerialMessagingClient, endpoint, data, user_data) -> None:
        print("on_response()")

    # Caller only.
    def on_call_error(self, client: SerialMessagingClient, endpoint, status, user_data) -> None:
        print("on_request()")

    # Callee only.
    def on_request(self, client: SerialMessagingClient, endpoint, data,
                   user_data) -> Tuple[Status, Optional[bytearray]]:
        print("on_request()")


# class MyClientCallbacks(BaseClientCallbacks):
#     pass


class SerialProtocol(asyncio.Protocol):

    def __init__(self):
        # Set later, after the instantiation by the factory.
        self.__client = None

    def set_client(self, client: SerialMessagingClient):
        self.__client = client

    def connection_made(self, transport: BaseTransport):
        self.transport = transport
        print(f"port opened", flush=True)
        # print(f"Protocol.__client = {self.__client}",  flush=True)
        transport.serial.rts = False
        # transport.write(b'Hello, World!\n')
        # print(f"Slots: {self.__slots__}", flush=True)

    def data_received(self, data: bytes):
        b = bytearray(data)
        # print(f"data received {b.hex(sep=' ')}", flush=True)
        self.__client.receive(b)
        # print(f"Protocol.__client = {self.__client}",  flush=True)
        # print(f"RX: {packet_encoder.encode_packet(10, 4, bytearray([0x13, 0x00, 0x00, 0x00, 0x08, 0x00])).hex(sep=' ')}")

        # if b'\n' in data:
        #    self.transport.close()

    def connection_lost(self, exc):
        print('port closed', flush=True)
        # self.transport.loop.stop()

    def pause_writing(self):
        print('pause writing', flush=True)
        print(self.transport.get_write_buffer_size(), flush=True)

    def resume_writing(self):
        print(self.transport.get_write_buffer_size(), flush=True)
        print('resume writing', flush=True)


class SerialMessagingClient:

    def __init__(self, port: str, client_callbacks: BaseClientCallbacks, baudrate: int = 115200):
        self.__port = port
        self.__baudrate = baudrate
        self.__client_callbacks = client_callbacks
        self.__transport = None
        self.__protocol = None
        self.__packet_encoder = PacketEncoder()
        self.__packet_decoder = PacketDecoder()
        self.__tx_contexts = {}

    def __str__(self) -> str:
        return f"{self.__port}@{self.__baudrate}"
      
    def receive(self, b : bytearray):
      self.__packet_decoder.receive(b)

    async def connect(self):
        self.__transport, self.__protocol = await serial_asyncio.create_serial_connection(
            asyncio.get_event_loop(), SerialProtocol, self.__port, baudrate=self.__baudrate)
        self.__protocol.set_client(self)
        # Initial start byte. From now on we will send it onl at the end of each
        # packet.
        self.__transport.write(bytearray([0x7E]))
        return Status.OK

    async def send(self, endpoint: int, data: bytearray):
        packet, seq = self.__packet_encoder.encode_next_packet(endpoint, data)
        tx_context = TxContext(seq, endpoint)
        self.__tx_contexts[seq] = tx_context
        print(f"TX Packet: {tx_context}: {packet.hex(sep=' ')} (7e)")
        self.__transport.write(packet)
        self.__transport.write(bytearray([0x7E]))
