#include "rgb_led.h"
#include <Adafruit_NeoPixel.h>
#include "passive_timer.h"

// On Teensy LC, Arduino pin 17 is at 5V levels and matches
// the input requirements of the WS2812/B LEDs.
#define PIN   17

// Number of leds in the led strip. All leds are set to same
// color. Note that larger number of leds may increase the
// time period in which interrupts are disable and may interfere
// with the reception of the serial data (?).
#define NUM_LEDS  3

namespace rgb_led {

static PassiveTimer blink_timer;
static bool blink_signal;

static const Color OFF_COLOR = make_color(0, 0, 0);

static Color current_color = OFF_COLOR;

// 0 means no blink. Forced to be >= 0.
static int current_blink_millis = 0;

// Single LED
static Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUM_LEDS, PIN, NEO_GRB + NEO_KHZ800);

inline raw_set(Color color) {
  pixels.fill(color, 0, NUM_LEDS);
  pixels.show();
}

void setup() {
  pixels.begin();
  raw_set(current_color);
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
  raw_set(current_color);
}

}  // namepsace rgb_led;
