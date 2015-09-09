// Motor pins driver.

#include <arduino.h>

#include "motor_io.h"

// Using port D.
#define MOTOR_PORT      (PORTD)
#define MOTOR_PORT_DDR  (DDRD)

namespace motor_io {

// Using a single port for all 4 motor pins.
static const uint8_t kPin1Mask = (1 << 2);  // Arduino pin 2
static const uint8_t kPin2Mask = (1 << 3);  // Arduino pin 3
static const uint8_t kPin3Mask = (1 << 4);  // Arduino pin 4
static const uint8_t kPin4Mask = (1 << 5);  // Arduino pin 5

// Activated pins in each steps throughout one cycle.
static const uint8_t kStepTable[] = {
  kPin1Mask | kPin2Mask,   // step 0
  kPin2Mask,               // step 1
  kPin2Mask | kPin3Mask,   // step 2
  kPin3Mask,               // step 3
  kPin3Mask | kPin4Mask,   // step 4
  kPin4Mask,               // step 5
  kPin4Mask | kPin1Mask,   // step 6
  kPin1Mask                // step 7
};

// A union of all pin masks.
static const uint8_t kAllPinsMask = kPin1Mask | kPin2Mask | kPin3Mask | kPin4Mask;

// We consider only the last three bits of the step counter (8 steps per cycle).
static const uint8_t kStepMask = 0x7;

// Set 4 pins per their respective bits in values. All other bits of values
// are ignored.
static inline void updatePins(uint8_t values) {
  cli();
  MOTOR_PORT = ((MOTOR_PORT & ~kAllPinsMask) | values); 
  sei();  
}

void sleep() {
  updatePins(0);
}

void setStep(uint8_t step) {
  const uint8_t step_index = step & kStepMask;
  updatePins(kStepTable[step_index]);
}

void setup() {
  // Set motor pins as outputs.
  MOTOR_PORT_DDR |= kAllPinsMask;
  
  // Pins are off.
  updatePins(0);
}
  
}  // namespace motor_io

