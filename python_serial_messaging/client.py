from __future__ import annotations

import asyncio
import serial_asyncio
import logging
import time

from enum import Enum
from typing import Callable, Optional, TypeVar, Iterable, Tuple
# from asyncio.protocols import BaseProtocol
from asyncio.transports import BaseTransport
from packet_encoder import PacketEncoder
from packet_decoder import PacketDecoder, DecodedPacket
from packets import PACKET_DEL, PacketType

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

    def __init__(self, seq: int, future: asyncio.Future):
        self.__seq = seq
        self.__future = future
        self.__time = time.time()

    def __str__(self):
        return f"tx_context {self.__seq}"
      
    def set_result(self, status: int, data: Optional(bytearray)):
       self.__future.set_result((status, data))
       
    def time(self):
      return self.__time


class RxContext:
    pass


class BaseClientCallbacks:

    # Caller and callee.
    def on_open(self, client: SerialMessagingClient) -> None:
        print("on_open()")

    # Caller and callee.
    def on_close(self, client: SerialMessagingClient) -> None:
        print("on_close()")

    # Caller only.
    def on_response(self, client: SerialMessagingClient, endpoint, data, user_data) -> None:
        print("on_response()")

    # Caller only.
    # def on_call_error(self, client: SerialMessagingClient, endpoint, status, user_data) -> None:
    #     print("on_request()")

    # Callee only.
    def on_command(
        self,
        # client: SerialMessagingClient,
        endpoint: int,
        data: bytearray,
    ) -> Tuple[Status, Optional[bytearray]]:
        print("Missing handling of on_command_with_resp", flush=True)
        return (0xff, None)


# class MyClientCallbacks(BaseClientCallbacks):
#     pass


class SerialProtocol(asyncio.Protocol):

    def __init__(self):
        # Set later, after the instantiation by the factory.
        self.__client = None
        self.__packet_decoder = None

    def set(self, client: SerialMessagingClient, packet_decoder: PacketDecoder):
        self.__client = client
        self.__packet_decoder = packet_decoder

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
        # self.__client.receive(b)

        self.__packet_decoder.receive(b)
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
        self.__command_id_counter = 0
        self.__tx_contexts = {}
        # self.__rx_tasks = asyncio.TaskGroup()

        for i in range(3):
            asyncio.create_task(self.__rx_task_body(f"rx_task_{i+1:02d}"))
            
        asyncio.create_task(self.__cleanup_task_body(f"cleanup"))

    def __str__(self) -> str:
        return f"{self.__port}@{self.__baudrate}"

    # def receive(self, b : bytearray):
    #   self.__packet_decoder.receive(b)

    async def __rx_task_body(self, task_name: str):
        print(f"RX task {task_name} started", flush=True)
        while True:
            packet: DecodedPacket = await self.__packet_decoder.get_next_packet()
            # print(f"{task_name}: got packet {packet}", flush=True)
            packet.dump(f"{task_name} got packet:")
            if packet.is_command():
                await self.__handle_command_packet(packet)
            elif packet.is_response():
                await self.__handle_response_packet(packet)
            else:
                print(f"Unknown packet type {packet.type}, dropping")
                # TODO: handle the other cases.
                pass
              
    async def __cleanup_task_body(self, task_name: str):
        print(f"Cleanup task {task_name} started", flush=True)
        while True:
          await asyncio.sleep(1)
          cutoff_time = time.time() - 1.0
          print(f"Cleanup...", flush=True)
          keys = list(self.__tx_contexts.keys())
          for seq in keys:
            tx_context = self.__tx_contexts.get(seq)
            if tx_context.time() < cutoff_time:
              print(f"Cleaning timeout command {seq}", flush=True)
              tx_context.set_result(0xff, None)
              self.__tx_contexts.pop(seq, None)
            

          

          
        

    async def __handle_command_packet(self, packet: DecodedPacket):
        print(f"Handling command with resp packet", flush=True)
        assert (packet.is_command())
        status, data = self.__client_callbacks.on_command( packet.endpoint,
                                                                    packet.data)
        response_packet  = self.__packet_encoder.encode_response_packet(packet.seq, status, data)
        self.__transport.write(response_packet)
        # self.__transport.write(bytearray([PACKET_DEL]))
        
        
    async def __handle_response_packet(self, packet: DecodedPacket):
        print(f"Handling resp packet ({len(self.__tx_contexts)} tx contexts)", flush=True)
        assert (packet.is_response())
        tx_context: TxContext = self.__tx_contexts.pop(packet.seq, None)
        if not tx_context:
           print(f"Response has no matching context {packet.seq}, dropping", flush=True)
           return
        print(f"Found tx context for response {packet.seq}", flush=True)
        tx_context.set_result(packet.status, packet.data)

        # TODO: set the txt context future.
          
        # @ match to TxContex
        # @ release blocked caller
        
        # status, data = self.__client_callbacks.on_command_with_resp(self, packet.endpoint,
        #                                                             packet.data)
        # response_packet, seq = self.__packet_encoder.encode_response_packet(status, data)
        # self.__transport.write(response_packet)
        # self.__transport.write(bytearray([PACKET_DEL]))

    async def connect(self):
        self.__transport, self.__protocol = await serial_asyncio.create_serial_connection(
            asyncio.get_event_loop(), SerialProtocol, self.__port, baudrate=self.__baudrate)
        self.__protocol.set(self, self.__packet_decoder)
        # Initial start byte. From now on we will send it onl at the end of each
        # packet.
        self.__transport.write(bytearray([0x7E]))
        return Status.OK

    # TODO: annotate returned type
    async def send_command(self, endpoint: int, data: Optional(bytearray)) -> Tuple([int, Optional(bytearray)]):
        assert (endpoint >= 0 and endpoint <= 255)
        self.__command_id_counter += 1
        seq = self.__command_id_counter
        packet = self.__packet_encoder.encode_command_packet(seq, endpoint, data)
        future = asyncio.Future()
        tx_context = TxContext(seq, future)
        self.__tx_contexts[seq] = tx_context
        print(f"TX Packet: {seq}: {packet.hex(sep=' ')}")
        self.__transport.write(packet)
        status, data = await future
        return (status, data)
        # self.__transport.write(bytearray([PACKET_DEL]))
