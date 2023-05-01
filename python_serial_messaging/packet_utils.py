from __future__ import annotations

import asyncio
import logging
from enum import Enum
from typing import Callable, Optional, TypeVar, Iterable, Tuple
from PyCRC.CRCCCITT import CRCCCITT
from PyCRC.CRC16 import CRC16

logger = logging.getLogger("packet_utils")
logging.basicConfig(level=logging.INFO)


def calculate_crc(data):
    """Returns a 2 bytes crc"""
    calc = CRCCCITT("FFFF")
    crc = calc.calculate(bytes(data))
    b = crc.to_bytes(2, 'big')
    return b

def construct_packet(seq: int, endpoint: int, data: bytearray):
    """Construct the packet, without HDLC escaping"""
    # Construct the unescaped packet.
    packet = bytearray()
    packet.extend(seq.to_bytes(4, 'big'))
    packet.extend(endpoint.to_bytes(2, 'big'))
    packet.extend(data)
    crc = calculate_crc(packet)
    packet.extend(crc)
    return packet
  
def escape_packet(packet: bytearray):
    """Encode the packet in HDLC format"""
    result = bytearray()
    for byte in packet:
        if byte == 0x7E or byte == 0x7D:
            result.append(0x7D)
            result.append(byte ^ 0x20)
        else:
            result.append(byte)
    return result

def encode_packet(seq: int, endpoint: int, data: bytearray):
    """Returns packet in wire representation, without the start/end bytes"""
    packet = construct_packet(seq, endpoint, data)
    result = escape_packet(packet)
    return result;
    

  
