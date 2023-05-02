from __future__ import annotations

import logging
import asyncio
from PyCRC.CRCCCITT import CRCCCITT
from typing import  Optional
from packets import PacketType, PACKET_DEL, PACKET_ESC, PACKET_MAX_LEN

logger = logging.getLogger("packet_decoder")
logging.basicConfig(level=logging.INFO)


class DecodedPacket:
    def __init__(self, cmd_id: int, type: PacketType, endpoint: Optional(int), status: Optional(int),
                 data: bytearray):
        self.cmd_id = cmd_id
        self.type = type
        self.endpoint = endpoint
        self.status = status
        self.data = data

    def __str__(self):
        return f"{self.cmd_id}, {self.endpoint}, {len(self.data)}"

    def dump(self, title="Decoded packet"):
        print(f"{title}", flush=True)
        print(f"  Cmd id   {self.cmd_id: 10d}", flush=True)
        print(f"  Type   {self.type.name}", flush=True)
        print(f"  Endpoint   {self.endpoint}", flush=True)
        print(f"  Status   {self.status}", flush=True)
        print(f"  Data: {self.data.hex(sep=' ')}", flush=True)


class PacketDecoder:

    def __init__(self):
        self.__crc_calc = CRCCCITT("FFFF")
        self.__packet_bfr = bytearray()
        self.__in_packet = False
        self.__pending_escape = False
        self.__packet_bfr.clear()
        self.__packets_queue = asyncio.Queue()

    def __str__(self):
        return f"In_packet ={self.__in_packet}, pending_escape={self.__pending_escape}, len={len(self.__packet_bytes)}"

    def __reset_packet(self):
        # self.__state = state
        self.__in_packet = False
        self.__pending_escape = False
        self.__packet_bfr.clear()

    async def get_next_packet(self):
        """Blocking asyncio fetch of next pending packet."""
        return await self.__packets_queue.get()

   

    def receive(self, data: bytes):
        for b in data:
            self.__receive_byte(b)

    def __receive_byte(self, b: int):
        # If not already in a packet, wait for next flag.
        if not self.__in_packet:
            if b == PACKET_DEL:
                # Start collecting a packet.
                self.__in_packet = True
                self.__pending_escape = False
                self.__packet_bfr.clear()
            return

        # Here collecting packet bytes. Handle end of packet.
        assert (self.__in_packet)
        if b == PACKET_DEL and not self.__pending_escape:
            self.__process_packet()
            self.__reset_packet()
            # No need to wait for additional PACKET_DEL before next packet.
            self.__in_packet = True
            return

        # Check for size overrun
        if len(self.__packet_bfr) >= PACKET_MAX_LEN:
            print("Packet too long, dropping", flush=True)
            self.__reset_packet()
            return

        # Handle escape byte
        if b == PACKET_ESC:
            if self.__pending_escape:
                print("Error, two consecutive escape chars", flush=True)
                self.__reset_packet()
            else:
                self.__pending_escape = True
            return

        # Handle escaped byte.
        if self.__pending_escape:
            b1 = b ^ 0x20
            if b1 != PACKET_DEL and b1 != PACKET_ESC:
                print(f"Error, invalid escaped char {b1} ({b})", flush=True)
                self.__reset_packet()
            else:
                self.__packet_bfr.append(b1)
                self.__pending_escape = False
            return

        # Handle normal byte
        self.__packet_bfr.append(b)

    def __process_packet(self):
        rx_bfr = self.__packet_bfr
        # print(f"RX packet: {rx_bfr.hex(sep=' ')} (7e)", flush=True)

        # Ignore empty packets
        n = len(rx_bfr)
        if not n:
            # Zero length packet can occur normally if we insert
            # a pre packet delimiter byte.
            return

        # Check for minimum length. A minimum we should
        # have a type byte and two CRC bytes.
        if n < 3:
            print("Packet too short ({n}), dropping", flush=True)
            return

        # Check CRC
        packet_crc = int.from_bytes(rx_bfr[-2:], byteorder='big', signed=False)
        computed_crc = self.__crc_calc.calculate(bytes(rx_bfr[:-2]))
        if computed_crc != packet_crc:
            print(f"Packet CRC error {packet_crc: 04x} vs {computed_crc: 04x}, dropping",
                  flush=True)
            return

        # Construct decoded packet
        type_value = rx_bfr[0]
        if type_value == PacketType.COMMAND.value:
            type = PacketType.COMMAND
            cmd_id = int.from_bytes(rx_bfr[1:5], byteorder='big', signed=False)
            endpoint = rx_bfr[5]
            data = rx_bfr[6:-2]
            decoded_packet = DecodedPacket(cmd_id, type, endpoint, None, data)
        elif type_value == PacketType.RESPONSE.value:
            type = PacketType.RESPONSE
            cmd_id = int.from_bytes(rx_bfr[1:5], byteorder='big', signed=False)
            status = rx_bfr[5]
            data = rx_bfr[6:-2]
            decoded_packet = DecodedPacket(cmd_id, type, None, status, data)
        else:
            print(f"Invalid packet type {type.value: 02x}, dropping", flush=True)
            return

        # decoded_packet.dump()
        self.__packets_queue.put_nowait(decoded_packet)

       
