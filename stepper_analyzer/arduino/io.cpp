
#include "io.h"
#include <arduino.h>

namespace io {

static const int PUSH_BUTTON1_PIN = 18;
static const int PUSH_BUTTON2_PIN = 19;

Bounce push_button1 = Bounce(PUSH_BUTTON1_PIN, 10);  // 10 ms debounce
Bounce push_button2 = Bounce(PUSH_BUTTON2_PIN, 10);  // 10 ms debounce

void setup() {
  // Leds
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  pinMode(LED3_PIN, OUTPUT);

  reset_led2();
  reset_led2();
  reset_led2();

   // Buttons
  pinMode(PUSH_BUTTON1_PIN, INPUT_PULLUP);
  pinMode(PUSH_BUTTON2_PIN, INPUT_PULLUP);
}


}  // namespace io
