
#include <arduino.h>
#include "io.h"

namespace io {

// LEDs. Active high.
DigitalOutPin LED0(PORTE, 2, 1);
DigitalOutPin LED1(PORTB, 2, 1);
DigitalOutPin LED2(PORTC, 6, 1);
DigitalOutPin LED3(PORTC, 5, 1);

// MOSFET gate output. Active high.
DigitalOutPin GATE(PORTC, 4, 1);

// Current sense input.
AnalogInPin CURRENT_SENSE(15);

// Rotary inputs. Active low.
static DigitalInPin ROT1(PORTD, 0, 0);
static DigitalInPin ROT2(PORTD, 1, 0);
static DigitalInPin ROT4(PORTD, 2, 0);
static DigitalInPin ROT8(PORTD, 3, 0);

// Remote switch. Active low.
DigitalInPin REMOTE_SWITCH(PORTA, 0, 0);

int rotary_read() {
  int value = 0;
  value +=  ROT1.is_on() ? 1 :0;
  value +=  ROT2.is_on() ? 2 :0;
  value +=  ROT4.is_on() ? 4 :0;
  value +=  ROT8.is_on() ? 8 :0;
  return value;
}

// USB serial printf.
static char buffer[200];

void printf(const char* format, ...) {
  va_list argptr;
  va_start(argptr, format);
  vsnprintf(buffer, sizeof(buffer), format, argptr);
  Serial.print(buffer);
  va_end(argptr);
}


int AnalogInPin::read() {
  // Select input
  ADC0.MUXPOS = ain_;

  // Single reading. No accomulation.
  ADC0.CTRLB = 0;

  // Ref = VDD, Capacitance, clock /16
  ADC0.CTRLC = 0x53;

  // Start a conversion.
  ADC0.COMMAND = ADC_STCONV_bm;

  // Wait for conversion done.
  while (!(ADC0.INTFLAGS & ADC_RESRDY_bm)) {};

  // Read the 16 bit value with interrupts disabled.
  const  uint8_t status = SREG;
  cli();
  const uint8_t low = ADC0.RESL;
  const uint8_t high = ADC0.RESH;
  SREG = status;

  // Combine and return.
  return (high << 8) | low;
}

void dump_adc0_registers() {
  io::printf("ADC0:\n");
  io::printf("  CTRLA:    0x%02x\n", ADC0.CTRLA);
  io::printf("  CTRLB:    0x%02x\n", ADC0.CTRLB);
  io::printf("  CTRLC:    0x%02x\n", ADC0.CTRLC);
  io::printf("  CTRLD:    0x%02x\n", ADC0.CTRLD);
  io::printf("  CTRLE:    0x%02x\n", ADC0.CTRLE);
  io::printf("  SAMPCTRL: 0x%02x\n", ADC0.SAMPCTRL);
  io::printf("  MUXPOS:   0x%02x\n", ADC0.MUXPOS);
  io::printf("  COMMAND:  0x%02x\n", ADC0.COMMAND);
  io::printf("  EVCTRL:   0x%02x\n", ADC0.EVCTRL);
}

}  // namespace io
