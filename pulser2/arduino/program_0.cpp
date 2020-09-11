
#include "programs.h"
#include "io.h"

static int counter = 0;

void Program_0::setup() {
  
}

void Program_0::loop() {
  counter++;
  io::printf("Program 0 loop %d\n", counter);
  delay(300);
}
