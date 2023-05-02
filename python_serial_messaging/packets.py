from __future__ import annotations

import logging
from enum import Enum
from PyCRC.CRCCCITT import CRCCCITT
from typing import Callable, Optional, TypeVar, Iterable, Tuple


logger = logging.getLogger("packets")
logging.basicConfig(level=logging.INFO)

PACKET_DEL = 0x7E
PACKET_ESC = 0X7D

# Prefix a packet with a delimiter only if loner than this 
# time in secs from previous packet.
PRE_DEL_TIMEOUT = 1.0

# Max size of a non byte stuffed packet. Stuffed version may
# be larger due to the escaping.
PACKET_MAX_LEN = 1024
# PACKET_MIN_LEN = 8

class PacketType(Enum):
    COMMAND = 1
    RESPONSE = 2

