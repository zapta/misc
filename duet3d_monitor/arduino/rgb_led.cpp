#include "rgb_led.h"
#include <Adafruit_NeoPixel.h>
#include "passive_timer.h"

#define PIN            12


namespace rgb_led {

static PassiveTimer blink_timer;
static bool blink_signal;

static const Color OFF_COLOR = make_color(0, 0, 0);

static Color current_color = make_color(0, 0, 100);

static bool current_blink = false;

// Single LED
static Adafruit_NeoPixel pixels = Adafruit_NeoPixel(1, PIN, NEO_GRB + NEO_KHZ800);

void setup() {
  pixels.begin();
  pixels.setPixelColor(0, current_color);
  pixels.show();
  blink_timer.restart();
}

void loop() {
  if (current_blink && blink_timer.timeMillis() > 300) {
    blink_timer.restart();
    blink_signal = !blink_signal;
    pixels.setPixelColor(0, blink_signal ? OFF_COLOR : current_color);
    pixels.show();
  }
}

Color make_color(uint8_t r, uint8_t g, uint8_t b) {
  return  pixels.Color(r, g, b);
}

void set(Color color, bool blink) {
  if (color == current_color && blink == current_blink) {
    return;
  }
  current_blink = blink;
  current_color = color;
  // TODO: impove transitions when blinking.
  blink_timer.restart();
  blink_signal = false;
  pixels.setPixelColor(0, current_color);
  pixels.show();
}

}  // namepsace rgb_led;
