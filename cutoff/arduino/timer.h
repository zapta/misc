
#ifndef TIMER_H
#define TIMER_H

#include <arduino.h>
//#include "system_clock.h"

class Timer {
public:
  Timer() {
    restart();
  }

  inline void restart() {
    start_time_millis_ = millis();
  }

  //void copy(const Timer &other) {
  //  start_time_millis_ = other.start_time_millis_;
  //}

  inline uint32_t timeMillis() const {
    return millis() - start_time_millis_;
  }

private:
  uint32_t start_time_millis_;
};

#endif


