
#pragma once

#include <stdint.h>

#include "driver/gpio.h"
#include "io/button.h"

class OutputPin {
 public:
  OutputPin(gpio_num_t pin_num, uint32_t initial_state) : pin_num_(pin_num) {
    gpio_set_direction(pin_num_, GPIO_MODE_OUTPUT);
    write(initial_state);
  }

  inline void set() { write(1); }
  inline void clear() { write(0); }
  inline void toggle() { write(last_value_ ? 0 : 1); }
  // Value should be 0 or 1.
  inline void write(bool val) {
    last_value_ = val;
    gpio_set_level(pin_num_, val ? 1 : 0);
  }
  inline gpio_num_t pin_num() { return pin_num_; }

 private:
  const gpio_num_t pin_num_;
  // Used to toggle since we can't read output pins(?).
  bool last_value_ = 0;
};
