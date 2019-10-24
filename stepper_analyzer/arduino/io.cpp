
#include "io.h"
#include <arduino.h>

namespace io {

static const int BUTTON1_PIN = 18;
static const int BUTTON2_PIN = 19;

const uint32_t MAX_CLICK_MILLIs = 1000;
const uint32_t MIN_LONG_PRESS_MILLIS = 3000;

Button button1(BUTTON1_PIN, 10);
Button button2(BUTTON2_PIN, 10);

Button::Button(int pin, int interval)
  : _is_click(false), _is_long_press(false), _long_press_armed(false) {
  _bounce.attach(pin);
  _bounce.interval(10);
}

void Button::update() {
  _is_click = false;
  _is_long_press = false;

  _bounce.update();
  if (_bounce.fell()) {
    _long_press_armed = true;
    _elapsed_since_fell = 0;
  } else if (_bounce.rose()) {
    if (_elapsed_since_fell < MAX_CLICK_MILLIs) {
      _is_click = true;
    }
    _long_press_armed = false;
  }
  if (_long_press_armed && _elapsed_since_fell > MIN_LONG_PRESS_MILLIS) {
    _is_long_press = true;
    _long_press_armed = false;
  }
}

bool Button::is_click() {
  return _is_click;
}

bool Button::is_long_press() {
  return _is_long_press;
}

void setup() {
  // Leds
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  pinMode(LED3_PIN, OUTPUT);

  reset_led1();
  reset_led2();
  reset_led3();

  // Push buttons
  pinMode(BUTTON1_PIN, INPUT_PULLUP);
  pinMode(BUTTON2_PIN, INPUT_PULLUP);

  // Dip switches
  pinMode(DIP_SWITCH1_PIN, INPUT_PULLUP);
  pinMode(DIP_SWITCH2_PIN, INPUT_PULLUP);
  pinMode(DIP_SWITCH3_PIN, INPUT_PULLUP);
  pinMode(DIP_SWITCH4_PIN, INPUT_PULLUP);
}

}  // namespace io
