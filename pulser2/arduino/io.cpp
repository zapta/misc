
#include "io.h"

namespace io {



// Rotary selector
constexpr int ROT1 = 17;
constexpr int ROT2 = 16;
constexpr int ROT4 = 15;
constexpr int ROT8 = 14;


void setup() {
  pinMode(ROT1, INPUT_PULLUP);
  pinMode(ROT2, INPUT_PULLUP);
  pinMode(ROT4, INPUT_PULLUP);
  pinMode(ROT8, INPUT_PULLUP);
}

// Read a rotary bit. Return 0 or bit mask.
static int rotary_read_bit(int pin, int bit_mask) {
  // Rotary inputs are active low.
  return digitalRead(pin)
         ? 0
         : bit_mask;
}

int rotary_read() {
  return rotary_read_bit(ROT1, 1) +
         rotary_read_bit(ROT2, 2) +
         rotary_read_bit(ROT4, 4) +
         rotary_read_bit(ROT8, 8);
}

static char buffer[200];

void printf(const char* format, ...) {
    va_list argptr;
    va_start(argptr, format);
    vsnprintf(buffer, sizeof(buffer), format, argptr);
    Serial.print(buffer);
    va_end(argptr);
}



}  // namespace io
