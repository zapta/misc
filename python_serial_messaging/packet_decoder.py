from __future__ import annotations

import logging
from enum import Enum
# import packet_utils
from PyCRC.CRCCCITT import CRCCCITT
# from PyCRC.CRC16 import CRC16

logger = logging.getLogger("packet_decoder")
logging.basicConfig(level=logging.INFO)


class State(Enum):
    IDLE = 1
    IN_PACKET = 2


class PacketDecoder:

    def __init__(self):
        self.__crc_calc = CRCCCITT("FFFF")
        self.__packet_bfr = bytearray()
        self.__reset()

    def __str__(self):
        return f"{self.__state}, {len(self.__packet_bytes)}"

    def __reset(self, state=State.IDLE):
        self.__state = state
        self.__packet_bfr.clear()
        self.__pending_escape = False

    def receive(self, data: bytearray):
        # print(f"data received {data.hex(sep=' ')}", flush=True)
        for b in data:
            self.__receive_byte(b)

    def __receive_byte(self, b: int):
        # print(f"-- {b:02x}", flush=True)

        # In IDLE mode, wait for next start byte.
        if self.__state == State.IDLE:
            if b == 0x7E:
                # Start found.
                self.__state = State.IN_PACKET
                self.__packet_bfr.clear()
                self.__pending_escape = False
            return

        # Here collecting packet bytes. Handle end of packet.
        assert (self.__state == State.IN_PACKET)
        if b == 0x7E and not self.__pending_escape:
            self.__process_packet()
            # No need to wait for 0x7E before next packet.
            self.__reset(State.IN_PACKET)
            return

        # Check for size
        if len(self.__packet_bfr) >= 1024:
            print("Packet too long, dropping", flush=True)
            self.__reset()
            return

        # Handle escape byte
        if b == 0x7D:
            if self.__pending_escape:
                print("Error, two consecutive escape chars", flush=True)
                self.__reset()
            else:
                self.__pending_escape = True
            return

        # Handle escaped byte.
        if self.__pending_escape:
            b1 = b ^ 0x20
            if b1 != 0x7E and b1 != 0x7D:
                print(f"Error, invalid escaped char {b1} ({b})", flush=True)
                self.__reset()
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

        print("\nRX Packet", flush=True)
        print(f"  Seq   {seq: 10d}", flush=True)
        print(f"  Endpoint   {endpoint: 6d}", flush=True)
        print(f"  Data: {data.hex(sep=' ')}", flush=True)
