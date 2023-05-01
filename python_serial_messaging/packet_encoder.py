from __future__ import annotations

import logging
from PyCRC.CRCCCITT import CRCCCITT

logger = logging.getLogger("packet_encoder")
logging.basicConfig(level=logging.INFO)

class PacketEncoder:
  def __init__(self):
        self.__packets_counter = 0
        self.__crc_calc = CRCCCITT("FFFF")
        
  def __construct_packet(self, seq:int, endpoint: int, data: bytearray):
      """Construct packet, without byte stuffing"""
      packet = bytearray()
      packet.extend(seq.to_bytes(4, 'big'))
      packet.extend(endpoint.to_bytes(2, 'big'))
      packet.extend(data)
      crc = self.__crc_calc.calculate(bytes(packet))
      # print(f"CRC: {packet.hex(sep=' ')} -> {crc}", flush=True)
      packet.extend(crc.to_bytes(2, 'big'))
      return packet
  
  def __stuff_bytes(self, packet: bytearray):
      """Byte stuff the packet using HDLC format"""
      result = bytearray()
      for byte in packet:
          if byte == 0x7E or byte == 0x7D:
              result.append(0x7D)
              result.append(byte ^ 0x20)
          else:
              result.append(byte)
      return result

  def encode_next_packet(self, endpoint: int, data: bytearray):
      """Returns a packet in wire format"""
      self.__packets_counter += 1
      packet = self.__construct_packet(self.__packets_counter, endpoint, data)
      stuffed_packet = self.__stuff_bytes(packet)
      return (stuffed_packet, self.__packets_counter)
    

  
