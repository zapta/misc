#pragma once

// #include "common.h"
// #include "misc/io.h"
#include "io/input_pin.h"

class DebouncedInput {
 public:
   DebouncedInput(InputPin& in_pin);
  //   : in_pin_(in_pin) {
  //   last_in_value_ = in_pin_.is_high();
  //   stable_state_ = last_in_value_;
  //   changing_ = false;
  //   change_start_rtos_ticks_ = millis();
  // }

  // Returns the is_on() state.
  bool update(uint32_t millis_now);

  inline bool is_on() { return stable_state_; }

  void dump_state();

 private:
  InputPin&  in_pin_;
  bool last_in_value_;
  bool stable_state_;
  bool changing_;
  uint32_t change_start_millis_;
};