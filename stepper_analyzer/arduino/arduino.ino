// Skeleton program for reading two input analog channels.
// Designed for Teensy 4.0.

#include "display.h"
#include "acquisition.h"
#include "io.h"
#include <string.h>
#include <stdio.h>
#include <elapsedMillis.h>
#include <EEPROM.h>

static elapsedMillis millis_since_display_update;

struct EepromData {
  int offset1;
  int offset2;
};

// EEPROM address for storing configuration. This is an arbitrary value.
static const uint32_t EEPROM_ADDRESS = 16;

static int screen_num = 3;
static bool full_redraw = true;

static acquisition::State acq_state;

static int screen_updates_since_last_capture;
static bool capture_pending;
static acquisition::CaptureBuffer capture_buffer;
static bool capture_changed = true;

//static char buffer[300];


static void next_screen() {
  if (screen_num >= 0 && screen_num < 3) {
    screen_num++;
  } else {
    screen_num = 0;
  }
  if (screen_num == 3) {
    // Large to force immediate capture
    screen_updates_since_last_capture = 9999;
  }
  full_redraw = true;
}

static void update_display() {
  switch (screen_num) {
    case 0:
      acquisition::get_state(&acq_state);
      display::draw_info_screen(acq_state, full_redraw);
      break;
      
    case 1:
      acquisition::get_state(&acq_state);
      display::draw_time_histogram_screen(acq_state, full_redraw);
      break;
      
    case 2:
      acquisition::get_state(&acq_state);
      display::draw_amps_histogram_screen(acq_state, full_redraw);
      break;
          
    case 3:
        if (screen_updates_since_last_capture > 12  && acquisition::is_capture_ready()) {
           screen_updates_since_last_capture  = 0;
           acquisition::start_capture(48);
           capture_pending = true;
        }
        screen_updates_since_last_capture++;
       // acquisition::get_capture(&capture_buffer);
        display::draw_signals_screen(capture_buffer, full_redraw || capture_changed);
        capture_changed = false;
     // }
      break;
  }
  full_redraw = false;
}

static void calibrate_zeros() {
    acquisition::CalibrationData calibration_data;
    acquisition::calibrate_zeros(&calibration_data);
    EEPROM.put(EEPROM_ADDRESS, calibration_data);
    Serial.print("Calibrate: ");
    Serial.print(calibration_data.offset1);
    Serial.print(' ');
    Serial.println(calibration_data.offset2);
}


void setup() {
  Serial.begin(9600);

  io::setup();

  acquisition::CalibrationData calibration_data;
  EEPROM.get(EEPROM_ADDRESS, calibration_data);
  Serial.println();
  Serial.print("Calibration data: ");
  Serial.print(calibration_data.offset1);
  Serial.print(' ');
  Serial.println(calibration_data.offset2);
  acquisition::setup(calibration_data);

  display::setup();

  // Force display update on start
  millis_since_display_update = 999999;
}




void loop() {

  // Display
  if (millis_since_display_update >= 250) {
    Serial.print("Ready: "); Serial.print(acquisition::is_capture_ready()); Serial.print(" Pending: "); Serial.println(capture_pending);
    millis_since_display_update = 0;
    update_display();
  }

  if (capture_pending && acquisition::is_capture_ready()) {
    Serial.println("READY");
    acquisition::get_capture(&capture_buffer);
    //acquisition::dump_capture(capture_buffer);
    screen_updates_since_last_capture = 0;

    capture_pending = false;
    capture_changed = true;
  }

  // Button 1
  io::button1.update();
  if (io::button1.is_click()) {
    // Click: start capturing
    acquisition::start_capture(4);
    capture_pending = true;
  }
  if (io::button1.is_long_press()) {
    // Long press: zero current sensors.
    calibrate_zeros();
  }

  // Button 2
  io::button2.update();
  if (io::button2.is_click()) {
    // Click: next screen
    next_screen();
  }
  if (io::button2.is_long_press()) {
    // Long press: reset history
    acquisition::reset_history();
  }
}
