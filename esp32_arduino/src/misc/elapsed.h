#pragma once

#include <Arduino.h>
#include <stdint.h>
#include "util.h"

class Elapsed {
 public:
  Elapsed() { reset(millis()); }

  void reset(uint32_t millis_now) { start_millis_ = millis_now; }

  uint32_t elapsed_millis(uint32_t millis_now) { return millis_now - start_millis_; }

  void advance(uint32_t interval_millis) { start_millis_ += interval_millis; }

  void set(uint32_t elapsed_millis, uint32_t millis_now) {
    start_millis_ = millis_now - elapsed_millis;
  }

 private:
  uint32_t start_millis_;
};
