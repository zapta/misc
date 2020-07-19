
#include "io.h"
#include <arduino.h>

namespace io {


void setup() {
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  pinMode(LED3_PIN, OUTPUT);

  reset_led1();
  reset_led2();
  reset_led3();

}

}  // namespace io
