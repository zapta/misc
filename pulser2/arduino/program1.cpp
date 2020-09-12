
#include "programs.h"
#include "io.h"

namespace programs {
  
static int counter = 0;

void Program1::setup() {
  counter=111;
}

void Program1::loop() {
  counter++;
  io::printf("Program 1 loop %d, analog=%d\n", counter, io::CURRENT_SENSE.read());
  delay(300);
}

} // namespace programs
