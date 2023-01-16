#pragma once

#include <stdint.h>
#include "util.h"

class Elapsed {
 public:
  Elapsed() { reset(); }

  void reset() { start_millis_ = util::time_ms(); }

  uint32_t elapsed_millis() { return util::time_ms() - start_millis_; }

  void advance(uint32_t interval_millis) { start_millis_ += interval_millis; }

  void set(uint32_t elapsed_millis) {
    start_millis_ = util::time_ms() - elapsed_millis;
  }

 private:
  uint32_t start_millis_;
};
