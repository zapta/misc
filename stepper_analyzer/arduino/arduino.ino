// Skeleton program for reading two input analog channels.
// Designed for Teensy 4.0.

#include "display.h"
#include "acquisition.h"
#include "io.h"

#include <string.h>
#include <stdio.h>
#include <elapsedMillis.h>

static elapsedMillis millis_since_display_update;

void setup() {
  Serial.begin(9600);
  
  io::setup();
  acquisition::setup();
  display::setup();

  // Force display update on start
  millis_since_display_update = 999999;
}

void loop() {
  // Using static to avoid cost of repeating instantiatio. 
  static acquisition::State acq_state;
  
  // Display
  if (millis_since_display_update >= 250) {
    acquisition::get_state(&acq_state);
    display::update_screen(acq_state);
    millis_since_display_update = 0;
  }

  // Button 1 click: reset acquisition history.
  if (io::push_button1.update() && io::push_button1.fallingEdge()) {
    acquisition::reset_history();
  }

  // Button 2 click: switch to next screen
  if (io::push_button2.update() && io::push_button2.fallingEdge()) {
    display::next_screen();
  }
}
