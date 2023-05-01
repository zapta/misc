from __future__ import annotations

import logging
from enum import Enum
from dataclasses import dataclass
# import packet_utils
from PyCRC.CRCCCITT import CRCCCITT
from typing import Callable, Optional, TypeVar, Iterable, Tuple

# from PyCRC.CRC16 import CRC16

logger = logging.getLogger("packet_decoder")
logging.basicConfig(level=logging.INFO)


class DecodedPacket:

    def __init__(self, seq: int, endpoint: int, data: bytearray):
        self.seq = seq
        self.endpoint = endpoint
        self.data = data

    def dump(self):
        print("\nDecoded packet", flush=True)
        print(f"  Seq   {self.seq: 10d}", flush=True)
        print(f"  Endpoint   {self.endpoint: 6d}", flush=True)
        print(f"  Data: {self.data.hex(sep=' ')}", flush=True)


class PacketDecoder:

    # class State(Enum):
    #   IDLE = 1
    #   IN_PACKET = 2

    def __init__(self):
        self.__crc_calc = CRCCCITT("FFFF")
        self.__packet_bfr = bytearray()
        self.__in_packet = False
        self.__pending_escape = False
        self.__packet_bfr.clear()
        self.__decoded_packets = []

    def __str__(self):
        return f"In_packet ={self.__in_packet}, pending_escape={self.__pending_escape}, len={len(self.__packet_bytes)}"

    def __reset_packet(self):
        # self.__state = state
        self.__in_packet = False
        self.__pending_escape = False
        self.__packet_bfr.clear()

    def has_pending_packets(self) -> bool:
        return len(self.__decoded_packets) > 0

    def pop_pending_packet(self) -> Optional(DecodedPacket):
        """Return next pending packet. 
        Check has_pending_packets() first to make sure a packet is available. 
        packets are in order of arrival.
        """
        return self.__decoded_packets.pop(0)

    def receive(self, data: bytearray):
        # print(f"data received {data.hex(sep=' ')}", flush=True)
        for b in data:
            self.__receive_byte(b)

    def __receive_byte(self, b: int):
        # print(f"-- {b:02x}", flush=True)

        # In IDLE mode, wait for next start byte.
        if not self.__in_packet:
            if b == 0x7E:
                # Start found.
                # self.__sta = State.IN_PACKET
                self.__in_packet = True
                self.__pending_escape = False
                self.__packet_bfr.clear()

            return

        # Here collecting packet bytes. Handle end of packet.
        # assert (self.__state == State.IN_PACKET)
        assert (self.__in_packet)
        if b == 0x7E and not self.__pending_escape:
            self.__process_packet()

            # self.__reset(State.IN_PACKET)

            self.__reset_packet()
            # No need to wait for 0x7E before next packet.
            self.__in_packet = True
            return

        # Check for size
        if len(self.__packet_bfr) >= 1024:
            print("Packet too long, dropping", flush=True)
            self.__reset_packet()
            return

        # Handle escape byte
        if b == 0x7D:
            if self.__pending_escape:
                print("Error, two consecutive escape chars", flush=True)
                self.__reset_packet()
            else:
                self.__pending_escape = True
            return

        # Handle escaped byte.
        if self.__pending_escape:
            b1 = b ^ 0x20
            if b1 != 0x7E and b1 != 0x7D:
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

        # Check min size
        n = len(rx_bfr)
        if n < 8:
            print(f"RX packet too short ({n}), dropping", flush=True)
            return

        # Check CRC
        packet_crc = int.from_bytes(rx_bfr[-2:], byteorder='big', signed=False)
        # computed_crc = packet_utils.calculate_crc(rx_bfr[:-2])
        computed_crc = self.__crc_calc.calculate(bytes(rx_bfr[:-2]))
        if computed_crc != packet_crc:
            print(f"Packet CRC error {packet_crc: 04x} vs {computed_crc: 04x}, dropping",
                  flush=True)
            return

        # Extract fields
        seq = int.from_bytes(rx_bfr[0:4], byteorder='big', signed=False)
        endpoint = int.from_bytes(rx_bfr[4:6], byteorder='big', signed=False)
        data = rx_bfr[6:-2]

        decoded_packet = DecodedPacket(seq, endpoint, data)
        decoded_packet.dump()
        self.__decoded_packets.append(decoded_packet)
        # print("\nRX Packet", flush=True)
        # print(f"  Seq   {seq: 10d}", flush=True)
        # print(f"  Endpoint   {endpoint: 6d}", flush=True)
        # print(f"  Data: {data.hex(sep=' ')}", flush=True)
