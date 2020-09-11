
#ifndef IO__H
#define IO__H

#include <arduino.h>

namespace io {

  void setup();

  int rotary_read();

  // Can be called also before setup().
  void printf(const char* format, ...);
   
}  // namespace io


#endif // IO__H
