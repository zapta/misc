
#include "programs.h"
#include "io.h"

static int counter = 0;

void Program_1::setup() {
  counter=111;
}

void Program_1::loop() {
  counter++;
  io::printf("Program 1 loop %d\n", counter);
  delay(300);
}
