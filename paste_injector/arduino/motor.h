

#ifndef MOTOR_H
#define MOTOR_H

#include <arduino.h>


namespace motor {

extern void setup();

extern void loop();

extern void sleep();

// 0 indicates stop. Turns on motor is it's off.
extern void setSpeed(uint16_t steps_per_sec, boolean is_forward);
  
}  // namespace motor

#endif  // ifdef

