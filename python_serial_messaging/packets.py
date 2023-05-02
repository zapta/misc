from __future__ import annotations

import logging
from enum import Enum

PACKET_DEL = 0x7E
PACKET_ESC = 0X7D

# Prefix a packet with a delimiter only if loner than this
# time in secs from previous packet.
PRE_DEL_TIMEOUT = 1.0

# Max size of a non byte stuffed packet. Stuffed version may
# be larger due to the escaping.
PACKET_MAX_LEN = 1024


class PacketType(Enum):
    COMMAND = 1
    RESPONSE = 2


class PacketStatus(Enum):
    """Defines status codes. User NAME.value to convert to int. 
    valid values are [0, 255]
    """
    OK = 0
    GENERAL_ERROR = 1
    TIMEOUT = 2
    UNHANDLED = 3
    INVALID_ARGUMENT = 4
    LENGTH_ERROR = 5

    # Users can start allocating error codes from
    # here to 255.
    USER_ERRORS_BASE = 100
