from __future__ import annotations

import logging
import time
from PyCRC.CRCCCITT import CRCCCITT
from packets import PacketType, PACKET_DEL, PACKET_ESC, PACKET_MAX_LEN, PRE_DEL_TIMEOUT
from typing import Callable, Optional, TypeVar, Iterable, Tuple

logger = logging.getLogger("packet_encoder")


class PacketEncoder:

    def __init__(self):
        self.__packets_counter = 0
        self.__last_packet_time = 0
        self.__crc_calc = CRCCCITT("FFFF")

    def __construct_command_packet(self, cmd_id: int, endpoint: int, data: bytearray):
        """Construct command packet, before byte stuffing"""
        packet = bytearray()
        packet.append(PacketType.COMMAND.value)
        packet.extend(cmd_id.to_bytes(4, 'big'))
        packet.append(endpoint)
        packet.extend(data)
        crc = self.__crc_calc.calculate(bytes(packet))
        packet.extend(crc.to_bytes(2, 'big'))
        assert (len(packet) <= PACKET_MAX_LEN)
        return packet

    def __construct_response_packet(self, cmd_id: int, status: int, data: bytearray):
        """Construct response packet, before byte stuffing"""
        packet = bytearray()
        packet.append(PacketType.RESPONSE.value)
        packet.extend(cmd_id.to_bytes(4, 'big'))
        packet.append(status)
        packet.extend(data)
        crc = self.__crc_calc.calculate(bytes(packet))
        packet.extend(crc.to_bytes(2, 'big'))
        assert (len(packet) <= PACKET_MAX_LEN)
        return packet

    def __stuff_packet_bytes(self, packet: bytearray, insert_pre_del: bool):
        """Byte stuff the packet using HDLC format. Also adds packet delimiter(s)"""
        result = bytearray()
        if insert_pre_del:
            result.append(PACKET_DEL)
        for byte in packet:
            if byte == 0x7E or byte == 0x7D:
                result.append(0x7D)
                result.append(byte ^ 0x20)
            else:
                result.append(byte)
        result.append(PACKET_DEL)
        return result

    def __track_packet_rate(self):
        last_packet_time = self.__last_packet_time
        self.__last_packet_time = time.time()
        elapsed = self.__last_packet_time - last_packet_time
        # We insert a pre packet delimiter only if the packets are sparse.
        insert_pre_del = elapsed > PRE_DEL_TIMEOUT
        return insert_pre_del

    def encode_command_packet(self, cmd_id: int, endpoint: int, data: bytearray):
        """Returns a command packet in wire format"""
        insert_pre_del = self.__track_packet_rate()
        packet = self.__construct_command_packet(cmd_id, endpoint, data)
        stuffed_packet = self.__stuff_packet_bytes(packet, insert_pre_del)
        return stuffed_packet

    def encode_response_packet(self, cmd_id: int, status: int, data: bytearray):
        """Returns a packet in wire format."""
        insert_pre_del = self.__track_packet_rate()
        packet = self.__construct_response_packet(cmd_id, status, data)
        stuffed_packet = self.__stuff_packet_bytes(packet, insert_pre_del)
        return stuffed_packet
