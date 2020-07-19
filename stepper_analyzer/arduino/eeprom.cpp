
#include "eeprom.h"

#include <arduino.h>
#include <EEPROM.h>


namespace eeprom {

struct Payload {
  int offset1;
  int offset2;
  bool reverse_direction;
  uint32_t reserved[2];
};

struct EepromPacket {
  // The payload settings.
  Payload payload;
  // Checksup of settings.
  uint32_t checksum;
};

// EEPROM address for storing configuration. This is an arbitrary value.
static const uint32_t EEPROM_ADDRESS = 16;

// Temp buffer for read/write.
static EepromPacket packet;

//// Compute a trivial checksum of the payload in the packet buffer.
//static uint32_t packet_checksum() {
//  const uint8_t* const p = (uint8_t*)&packet.settings;
//  const int n = sizeof(packet.settings);
//  uint32_t result = 0x1234;
//  for (int i = 0; i<n; i++) {
//    result ^= p[i];
//  }
//  return result;
//}


// Compute checksum of payload in packet buffer.
// CRC function adopted from
// https://www.arduino.cc/en/Tutorial/EEPROMCrc
//
static uint32_t packet_checksum(void) {
  const uint8_t* const p = (uint8_t*) &packet.payload;
  const int n = sizeof(packet.payload);

  const unsigned long crc_table[16] = {
    0x00000000, 0x1db71064, 0x3b6e20c8, 0x26d930ac,
    0x76dc4190, 0x6b6b51f4, 0x4db26158, 0x5005713c,
    0xedb88320, 0xf00f9344, 0xd6d6a3e8, 0xcb61b38c,
    0x9b64c2b0, 0x86d3d2d4, 0xa00ae278, 0xbdbdf21c
  };

  unsigned long crc = ~0L;

  for (int index = 0 ; index < n  ; ++index) {
    crc = crc_table[(crc ^ p[index]) & 0x0f] ^ (crc >> 4);
    crc = crc_table[(crc ^ (p[index] >> 4)) & 0x0f] ^ (crc >> 4);
    crc = ~crc;
  }
  return crc;
}

static void dump_packet(const char* message) {
  Serial.printf("%s %d, %d, %d, %0x8\n",
                message,
                packet.payload.offset1,
                packet.payload.offset2,
                packet.payload.reverse_direction,
                packet.checksum);
}

static void read_packet() {
  EEPROM.get(EEPROM_ADDRESS, packet);
  dump_packet("EE Read:");
  if (packet_checksum() != packet.checksum) {
    Serial.println("EEProm packet checksum error. Resetting.");
    memset(&packet.payload, 0, sizeof(packet.payload));
    dump_packet("EE Reset:");
  }
}

void write_packet() {
  packet.checksum = packet_checksum();
  EEPROM.put(EEPROM_ADDRESS, packet);
  dump_packet("EE Write:");
}

void GetAcqSettings(acquisition::Settings* acq_settings) {
  read_packet();
  memset(acq_settings, 0, sizeof(*acq_settings));
  acq_settings->offset1 = packet.payload.offset1;
  acq_settings->offset2 = packet.payload.offset2;
  acq_settings->reverse_direction = packet.payload.reverse_direction;
}

void UpdateAcqSettings(const acquisition::Settings& acq_settings) {
  read_packet();
  packet.payload.offset1 = acq_settings.offset1;
  packet.payload.offset2 = acq_settings.offset2;
  packet.payload.reverse_direction = acq_settings.reverse_direction;
  write_packet();
}

}  // namespace eeprom
