#include "motor.h"

#include <arduino.h>

#include "motor_io.h"


namespace motor {

static uint8_t step_counter = 0;

static uint32_t last_step_micros = 0;
static boolean is_forward = true;

// If 0 indicates zero speed.
static uint32_t step_time_micros = 0;

bool isNonZeroSpeed() {
  return step_time_micros != 0;
}

static void doStep() {
  if (is_forward) {
    step_counter++;
  } else {
    step_counter--;
  }
  last_step_micros = micros();
  motor_io::setStep(step_counter);
}

void setup() {
  motor_io::setup();
  
  last_step_micros = micros(); 
  motor_io::setStep(step_counter);
}

void loop() {
  if (!step_time_micros) {
    last_step_micros = micros();
    return;
  }
  
  // TODO: cach the target time in micros?
  if ((micros() - last_step_micros) >= step_time_micros) {
    doStep();
  }
}

// 0 indicates stop.
void setSpeed(uint16_t steps_per_sec, boolean forward) {
  // Turn on the motor in case it was off.
  motor_io::setStep(step_counter);
  
  if (!steps_per_sec) {
    step_time_micros = 0;
    is_forward = forward;
    return;  
  }

  step_time_micros = (1000000L / steps_per_sec);
  is_forward = forward;
}

void sleep() {
  step_time_micros = 0;
  motor_io::sleep();
}

  
}  // namespace motor


