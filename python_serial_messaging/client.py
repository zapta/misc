from __future__ import annotations

import asyncio
import serial_asyncio
import logging
import time
from enum import Enum
from typing import Callable, Optional, TypeVar, Iterable, Tuple
import packet_encoder

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
    assert(endpoint > 0 and endpoint < 0xffff)
    self.__seq = seq
    self.__endpoint = endpoint


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

    def connection_made(self, transport):
        self.transport = transport
        print(f"port opened",  flush=True)
        print(f"Protocol.__client = {self.__client}",  flush=True)
        transport.serial.rts = False
        # transport.write(b'Hello, World!\n')
        # print(f"Slots: {self.__slots__}", flush=True)
      

    def data_received(self, data):
        print('data received', repr(data), flush=True)
        print(f"Protocol.__client = {self.__client}",  flush=True)
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


# loop = asyncio.get_event_loop()
# coro = serial_asyncio.create_serial_connection(loop, OutputProtocol, 'COM20', baudrate=115200)
# transport, protocol = loop.run_until_complete(coro)
# print("opened", flush=True)
# loop.run_forever()
# loop.close()


class SerialMessagingClient:

    def __init__(self, port: str, client_callbacks: BaseClientCallbacks, baudrate: int = 115200):
        self.__port = port
        self.__baudrate = baudrate
        self.__client_callbacks = client_callbacks
        self.__transport = None
        self.__protocol = None
        # TODO: Consider to initialize with a random 32 bit value value.
        self.__tx_counter = 0
        self.__tx_contexts = {}

    def __str__(self) -> str:
        return f"{self.__port}@{self.__baudrate}"

    async def connect(self):
        self.__transport, self.__protocol = await serial_asyncio.create_serial_connection(
            asyncio.get_event_loop(), SerialProtocol, self.__port, baudrate=self.__baudrate)
        self.__protocol.set_client(self)
        return Status.OK
      
    async def send(self, endpoint: int, data: bytearray):
      self.__tx_counter += 1
      packet = packet_encoder.encode_packet(self.__tx_counter, endpoint, data)
      tx_context = TxContext(self.__tx_counter, endpoint)
      self.__tx_contexts[self.__tx_counter] = tx_context
      print(f"TX {tx_context}: {packet.hex(sep=' ')}")
      self.__transport.write(packet)

      

    # # Internal method to fetch information of a specific BLE service.
    # async def __find_service_or_disconnect(self, name: str, uuid: str) -> (BleakGATTService | None):
    #     if not self.is_connected():
    #         logger.error(f"Not connected (__find_service_or_disconnect).")
    #         return None
    #     service = self.__client.services.get_service(uuid)
    #     if not service:
    #         logger.error(
    #             f"Failed to find service {name} at device {self.address()}.")
    #         await self.disconnect()
    #         return None
    #     logger.info(f"Found {name} info service {service}.")
    #     return service


# print("Main started")

# main_loop = asyncio.get_event_loop()
# client = SerialMessagingClient("COM20", MyClientCallbacks())
# status = main_loop.run_until_complete(client.connect())

# # coro = serial_asyncio.create_serial_connection(loop, OutputProtocol, 'COM20', baudrate=115200)

# # transport, protocol = loop.run_until_complete(coro)
# print("opened", flush=True)
# main_loop.run_forever()
# main_loop.close()
