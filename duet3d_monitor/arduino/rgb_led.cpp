#include "rgb_led.h"
#include <Adafruit_NeoPixel.h>
#include "passive_timer.h"

#define PIN            12


namespace rgb_led {

static PassiveTimer blink_timer;
static bool blink_signal;

static const Color OFF_COLOR = make_color(0, 0, 0);

static Color current_color = OFF_COLOR;

// 0 means no blink. Forced to be >= 0.
static int current_blink_millis = 0;

// Single LED
static Adafruit_NeoPixel pixels = Adafruit_NeoPixel(1, PIN, NEO_GRB + NEO_KHZ800);

void setup() {
  pixels.begin();
  pixels.setPixelColor(0, current_color);
  pixels.show();
  blink_timer.restart();
}

void loop() {
  if (current_blink_millis && blink_timer.timeMillis() > current_blink_millis) {
    blink_timer.restart();
    blink_signal = !blink_signal;
    pixels.setPixelColor(0, blink_signal ? OFF_COLOR : current_color);
    pixels.show();
  }
}

Color make_color(uint8_t r, uint8_t g, uint8_t b) {
  return  pixels.Color(r, g, b);
}

void set(Color color, int blink_millis) {
  // Force blink_millis >= 0
  if (blink_millis < 0) {
    blink_millis = 0;
  }
  if (color == current_color && blink_millis == current_blink_millis) {
    return;
  }
  current_blink_millis = blink_millis;
  current_color = color;
  // TODO: impove transitions when blinking.
  blink_timer.restart();
  blink_signal = false;
  pixels.setPixelColor(0, current_color);
  pixels.show();
}

}  // namepsace rgb_led;
