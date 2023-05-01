from __future__ import annotations

import asyncio
import serial_asyncio
import logging
import time
from enum import Enum
from typing import Callable, Optional, TypeVar, Iterable, Tuple
from client import BaseClientCallbacks, SerialMessagingClient, Status

# logger = logging.getLogger(__name__)
logger = logging.getLogger("main")
logging.basicConfig(level=logging.INFO)



class MyClientCallbacks(BaseClientCallbacks):
    pass
  
  




# #https://github.com/pyserial/pyserial-asyncio

# class Status(Enum):
#     OK = 1
#     InternalError = 2
#     TimeoutError = 3


# class BaseClientCallbacks:

#     # Caller and callee.
#     def on_open(self, client: SerialMessagingClient) -> None:
#         print("on_connect()")

#     # Caller and callee.
#     def on_close(self, client: SerialMessagingClient) -> None:
#         print("on_disconnect()")

#     # Caller only.
#     def on_response(self, client: SerialMessagingClient, endpoint, data, user_data) -> None:
#         print("on_response()")

#     # Caller only.
#     def on_call_error(self, client: SerialMessagingClient, endpoint, status, user_data) -> None:
#         print("on_request()")

#     # Callee only.
#     def on_request(self, client: SerialMessagingClient, endpoint, data,
#                    user_data) -> Tuple[Status, Optional[bytearray]]:
#         print("on_request()")


# class MyClientCallbacks(BaseClientCallbacks):
#     pass


# class SerialProtocol(asyncio.Protocol):
  
#     def __init__(self):
#       # Set later, after the instantiation by the factory.
#       self.__client = None 
      
#     def set_client(self, client: SerialMessagingClient):
#       self.__client = client

#     def connection_made(self, transport):
#         self.transport = transport
#         print(f"port opened",  flush=True)
#         print(f"Protocol.__client = {self.__client}",  flush=True)
#         transport.serial.rts = False
#         transport.write(b'Hello, World!\n')
#         print(f"Slots: {self.__slots__}", flush=True)

#     def data_received(self, data):
#         print('data received', repr(data), flush=True)
#         print(f"Protocol.__client = {self.__client}",  flush=True)

#         # if b'\n' in data:
#         #    self.transport.close()

#     def connection_lost(self, exc):
#         print('port closed', flush=True)
#         # self.transport.loop.stop()

#     def pause_writing(self):
#         print('pause writing', flush=True)
#         print(self.transport.get_write_buffer_size(), flush=True)

#     def resume_writing(self):
#         print(self.transport.get_write_buffer_size(), flush=True)
#         print('resume writing', flush=True)


# # loop = asyncio.get_event_loop()
# # coro = serial_asyncio.create_serial_connection(loop, OutputProtocol, 'COM20', baudrate=115200)
# # transport, protocol = loop.run_until_complete(coro)
# # print("opened", flush=True)
# # loop.run_forever()
# # loop.close()


# class SerialMessagingClient:

#     def __init__(self, port: str, client_callbacks: BaseClientCallbacks, baudrate: int = 115200):
#         self.__port = port
#         self.__baudrate = baudrate
#         self.__client_callbacks = client_callbacks
#         self.__transport = None
#         self.__protocol = None

#     def __str__(self) -> str:
#         return f"{self.__port}@{self.__baudrate}"

#     async def connect(self):
#         self.__transport, self.__protocol = await serial_asyncio.create_serial_connection(
#             asyncio.get_event_loop(), SerialProtocol, self.__port, baudrate=self.__baudrate)
#         self.__protocol.set_client(self)
#         return Status.OK

#     # # Internal method to fetch information of a specific BLE service.
#     # async def __find_service_or_disconnect(self, name: str, uuid: str) -> (BleakGATTService | None):
#     #     if not self.is_connected():
#     #         logger.error(f"Not connected (__find_service_or_disconnect).")
#     #         return None
#     #     service = self.__client.services.get_service(uuid)
#     #     if not service:
#     #         logger.error(
#     #             f"Failed to find service {name} at device {self.address()}.")
#     #         await self.disconnect()
#     #         return None
#     #     logger.info(f"Found {name} info service {service}.")
#     #     return service


async def async_main():
  print("Async main started", flush=True)
  client = SerialMessagingClient("COM20", MyClientCallbacks())
  status = await client.connect()
  print("Connected: status = {status}", flush=True)
  
  while True:
    await asyncio.sleep(3)
    print("Sleep done", flush=True)
    await client.send(1234,  bytearray([0x13, 0x00, 0x00, 0x00, 0x08, 0x00]))


    


    
    
print("Main started")

# main_loop = asyncio.get_event_loop()

# client = SerialMessagingClient("COM20", MyClientCallbacks())
# status = main_loop.run_until_complete(client.connect())

# task = asyncio.create_task(main_task())


# coro = serial_asyncio.create_serial_connection(loop, OutputProtocol, 'COM20', baudrate=115200)

# transport, protocol = loop.run_until_complete(coro)
asyncio.run(async_main())
# print("opened", flush=True)
# asyncio.run_forever()
# asyncio.close()
