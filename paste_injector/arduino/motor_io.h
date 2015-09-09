// Motor pins driver.

#ifndef MOTOR_IO_H
#define MOTOR_IO_H

#include <arduino.h>


namespace motor_io {

extern void sleep();

extern void setStep(uint8_t step);

extern void setup();
  
}  // namespace motor_io

#endif  // ifdef

