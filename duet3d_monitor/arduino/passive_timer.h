#ifndef PASSIVE_TIMER_H
#define PASSIVE_TIMER_H

#include <arduino.h>

class PassiveTimer {
public:
  PassiveTimer() {
    restart();
  }

  inline void restart() {
    start_time_millis_ = millis();
  }

  void copy(const PassiveTimer &other) {
    start_time_millis_ = other.start_time_millis_;
  }

  // Good for up to ~50 days from timer's last start/restart. 
  // Overflow after that.
  inline uint32_t timeMillis() const {
    return millis() - start_time_millis_;
  }

private:
  uint32_t start_time_millis_;
};

#endif
