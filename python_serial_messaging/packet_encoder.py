from __future__ import annotations

import asyncio
import serial_asyncio
import logging
import time
# import six
import struct
from enum import Enum
from typing import Callable, Optional, TypeVar, Iterable, Tuple
from PyCRC.CRCCCITT import CRCCCITT
from PyCRC.CRC16 import CRC16

# logger = logging.getLogger(__name__)
logger = logging.getLogger("client")
logging.basicConfig(level=logging.INFO)


def __calc_crc(data):
    """Returns a 2 bytes crc"""
    crccalc = CRCCCITT("FFFF")
    # crc = crccalc.calculate(six.binary_type(data))
    crc = crccalc.calculate(bytes(data))
    # crc = crccalc.calculate(data)
    # print(f"crc type: {type(crc)}", flush=True)
    # b = bytearray(struct.pack(">H", crc))
    b = crc.to_bytes(2, 'big')

    return b


def encode_packet(seq: int, endpoint: int, data: bytearray):
    """Encode the packet in HDLC format"""
    # Construct the unescaped frame.
    unescaped = bytearray()
    size = 8 + len(data)
    unescaped.extend(size.to_bytes(2, 'big'))
    unescaped.extend(seq.to_bytes(4, 'big'))
    unescaped.extend(endpoint.to_bytes(2, 'big'))
    unescaped.extend(data)
    crc = __calc_crc(unescaped)
    # print(f"len(crc) = {len(crc)}", flush=True)

    unescaped.extend(crc)

    # Construct the escaped frame.
    packet = bytearray()
    packet.append(0x7E)
    # print(f"len(unescaped) = {len(unescaped)}", flush=True)
    for byte in unescaped:
        if byte == 0x7E or byte == 0x7D:
            packet.append(0x7D)
            packet.append(byte ^ 0x20)
        else:
            packet.append(byte)
    packet.append(0x7E)

    return packet

    # crc = crc(packet[1:])
    # packet.extend(crc.to_bytes(2, 'big'))

    # assert (len(packet) == 4 + escape_count)
