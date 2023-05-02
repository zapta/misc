from __future__ import annotations

import asyncio
import serial_asyncio
import logging
import time
import inspect

from enum import Enum
from typing import Optional, Tuple, Dict, Callable
from asyncio.transports import BaseTransport
from packet_encoder import PacketEncoder
from packet_decoder import PacketDecoder, DecodedPacket
from packets import PacketType, PacketStatus

# import packet_utils

# logger = logging.getLogger(__name__)
logger = logging.getLogger("client")
logging.basicConfig(level=logging.INFO)

#https://github.com/pyserial/pyserial-asyncio


class _TxCommandContext:

    def __init__(self, cmd_id: int, expiration_time: float, future: asyncio.Future):
        self.__cmd_id = cmd_id
        self.__future = future
        self.__expiration_time = expiration_time

    def __str__(self):
        return f"cmd_context {self.__cmd_id}, {self.__expiration_time - time.time()} sec left"

    def set_result(self, status: int, data: Optional(bytearray)):
        self.__future.set_result((status, data))

    def is_expired(self):
        return time.time() > self.__expiration_time


# TODO: add override annotation to the methods.
class _SerialProtocol(asyncio.Protocol):

    def __init__(self):
        self.__packet_decoder: PacketDecoder = None

    def set(self, client: SerialMessagingClient, packet_decoder: PacketDecoder):
        self.__packet_decoder = packet_decoder

    def connection_made(self, transport: BaseTransport):
        print(f"port opened", flush=True)
        transport.serial.rts = False

    def data_received(self, data: bytes):
        self.__packet_decoder.receive(data)

    def connection_lost(self, exc):
        print('port closed', flush=True)

    def pause_writing(self):
        print('Writing paused', flush=True)

    def resume_writing(self):
        print('Writing resumed', flush=True)


class SerialMessagingClient:

    def __init__(self,
                 port: str,
                 command_async_callback: Optional(Callable[[int, bytearray],
                                                           Tuple(int, bytearray)]),
                 baudrate: int = 115200):
        self.__port = port
        self.__baudrate = baudrate
        self.__command_async_callback = command_async_callback
        self.__transport = None
        self.__protocol = None
        self.__packet_encoder = PacketEncoder()
        self.__packet_decoder = PacketDecoder()
        self.__command_id_counter = 0
        self.__tx_cmd_contexts: Dict[int, _TxCommandContext] = {}

        # Create a worker task to clean pending command contexts that were timeout.
        asyncio.create_task(self.__cleanup_task_body(), name="cleanup")

        # Create a few worker tasks to process incoming packets.
        for i in range(3):
            asyncio.create_task(self.__rx_task_body(), name=f"rx_task_{i+1:02d}")

    def __str__(self) -> str:
        return f"{self.__port}@{self.__baudrate}"

    async def connect(self):
        """Connect to serial port."""
        self.__transport, self.__protocol = await serial_asyncio.create_serial_connection(
            asyncio.get_event_loop(), _SerialProtocol, self.__port, baudrate=self.__baudrate)
        self.__protocol.set(self, self.__packet_decoder)

    async def __cleanup_task_body(self):
        """Body of the worker task that clean timeout tx command contexts"""
        print(f"Cleanup task '{asyncio.current_task().get_name()}' started", flush=True)
        while True:
            await asyncio.sleep(0.1)
            # print(f"Cleanup...", flush=True)
            # We can't delete while iterating the dict so iterating
            # on an independent list of keys instead.
            keys = list(self.__tx_cmd_contexts.keys())
            for cmd_id in keys:
                tx_context = self.__tx_cmd_contexts.get(cmd_id)
                if tx_context.is_expired():
                    print(f"Cleaning timeout command {cmd_id}", flush=True)
                    tx_context.set_result(0xff, bytearray())
                    self.__tx_cmd_contexts.pop(cmd_id)

    async def __rx_task_body(self):
        """Body of the worker tasks to serve incoming packets."""
        print(f"RX task '{asyncio.current_task().get_name()}' started", flush=True)
        while True:
            packet: DecodedPacket = await self.__packet_decoder.get_next_packet()
            # packet.dump(f"{task_name} got packet:")
            if packet.type == PacketType.COMMAND:
                await self.__handle_incoming_command_packet(packet)
                continue
            if packet.type == PacketType.RESPONSE:
                await self.__handle_incoming_response_packet(packet)
                continue
            print(f"Unknown incoming packet type {packet.type}, dropping")

    async def __handle_incoming_command_packet(self, packet: DecodedPacket):
        assert (packet.type == PacketType.COMMAND)
        if self.__command_async_callback:
            status, data = await self.__command_async_callback(packet.endpoint, packet.data)
        else:
            status, data = (PacketStatus.UNHANDLED.value, bytearray())
        response_packet = self.__packet_encoder.encode_response_packet(packet.cmd_id, status, data)
        self.__transport.write(response_packet)

    async def __handle_incoming_response_packet(self, packet: DecodedPacket):
        # print(f"Handling resp packet ({len(self.__tx_cmd_contexts)} tx contexts)", flush=True)
        assert (packet.type == PacketType.RESPONSE)
        tx_context: _TxCommandContext = self.__tx_cmd_contexts.pop(packet.cmd_id, None)
        if not tx_context:
            print(f"Response has no matching context {packet.cmd_id}, dropping", flush=True)
            return
        tx_context.set_result(packet.status, packet.data)

    async def send_command_blocking(self,
                                    endpoint: int,
                                    data: bytearray,
                                    timeout=1.0) -> Tuple([int, bytearray]):
        """Sends a command and waits for its result, or timeout"""
        future = self.send_command_future(endpoint, data, timeout=timeout)
        status, data = await future
        return (status, data)

    def send_command_future(self,
                            endpoint: int,
                            data: bytearray,
                            timeout=1.0) -> Tuple([int, bytearray]):
        """Sends a command and return a future for pending result"""
        assert (endpoint >= 0 and endpoint <= 255)
        assert (timeout >= 0.1 and timeout <= 5.0)
        # Allocate a fresh command id
        self.__command_id_counter += 1
        cmd_id = self.__command_id_counter
        assert (not cmd_id in self.__tx_cmd_contexts)
        # Encode packet bytes
        packet = self.__packet_encoder.encode_command_packet(cmd_id, endpoint, data)
        print(f"TX command packet: {cmd_id}: {packet.hex(sep=' ')}", flush=True)
        # Create command tx context
        expiration_time = time.time() + timeout
        future = asyncio.Future()
        tx_cmd_context = _TxCommandContext(cmd_id, expiration_time, future)
        self.__tx_cmd_contexts[cmd_id] = tx_cmd_context
        # Start sending
        self.__transport.write(packet)
        # Future will be signaled on response or timeout.
        return future
