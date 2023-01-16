#include "debounced_input.h"

#include <Arduino.h>

// #include "freertos/FreeRTOS.h"
// #include "freertos/task.h"

static constexpr uint32_t SETTLING_TIME_MILLIS = 100; 

DebouncedInput::DebouncedInput(InputPin& in_pin) : in_pin_(in_pin) {
    last_in_value_ = in_pin_.is_high();
    stable_state_ = last_in_value_;
    changing_ = false;
    change_start_millis_ = millis();
  }

bool DebouncedInput::update(uint32_t millis_now) {
  last_in_value_ = in_pin_.is_high();
  // Case 1: pin is same as stable state.
  if (stable_state_ == last_in_value_) {
    changing_ = false;
  }

  // Case 2: pin just starting a transition from a stable state.
  else if (!changing_) {
    changing_ = true;
    change_start_millis_ = millis_now;
  }

  // Case 3: Transition became stable.
  else if ((millis_now - change_start_millis_) >=
           SETTLING_TIME_MILLIS) {
    stable_state_ = !stable_state_;
    changing_ = false;
  }

  // Case 4: Nothing to do.
  else {
    // No change.
  }

  return stable_state_;
}

void DebouncedInput::dump_state() {
  // uint32_t a;
  printf("%u, %d, %d, %d, %u\n", in_pin_.pin_num(), last_in_value_,
         stable_state_, changing_, change_start_millis_);
}