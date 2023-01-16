
#pragma once

#include <stdint.h>

#include "driver/gpio.h"
// #include "misc/button.h"

class InputPin {
 public:
  InputPin(gpio_num_t pin_num, gpio_pull_mode_t pull_mode)
      : pin_num_(pin_num) {
    gpio_set_direction(pin_num_, GPIO_MODE_INPUT);
    gpio_set_pull_mode(pin_num_, pull_mode);
  }
  inline bool read() { return gpio_get_level(pin_num_); }
  inline bool is_high() { return read(); }
  inline bool is_low() { return !read(); }

  inline gpio_num_t pin_num() { return pin_num_; }

 private:
  const gpio_num_t pin_num_;
};
