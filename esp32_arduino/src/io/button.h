#pragma once

#include <Arduino.h>
#include "io/debounced_input.h"
#include "io/input_pin.h"

class Button {
 public:
  enum ButtonEvent {
    EVENT_NONE,
    EVENT_SHORT_CLICK,
    EVENT_LONG_PRESS,
    EVENT_LONG_RELEASE,
  };

  Button(InputPin& in_pin) : debounced_in_(in_pin) {
    state_ = STATE_RELEASED;
    time_start_rtos_ticks_ = millis();
  }

  // Returns the applicable button event for this update.
  ButtonEvent update(uint32_t millis_now);

  // Active low. Could check state_ instead.
  inline bool is_pressed() { return !debounced_in_.is_on(); }

  inline bool is_long_pressed() { return state_ == STATE_PRESSED_LONG; }

 private:
  enum State { STATE_RELEASED, STATE_PRESSED_IDLE, STATE_PRESSED_LONG };
  State state_;

  DebouncedInput debounced_in_;

  // Measure time in PRESSED_IDLE state.
  uint32_t time_start_rtos_ticks_;
};

// extern Button BUTTON1;

// extern void setup();

// }  // namespace button