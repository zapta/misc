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

static const uint32_t EEPROM_ADDRESS = 16;  // arbitrary

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

static char buffer[300];

void dumpAcqState(acquisition::State& acq_state) {
  static uint32_t last_isr_count = 0;

  sprintf(buffer, "[%lu][er:%lu|%lu] [%5d, %5d] [en:%d %lu] s:%d/%d  steps:%d",
          acq_state.isr_count - last_isr_count,
          acq_state.sampling_errors, acq_state.quadrature_errors,
          acq_state.display_v1, acq_state.display_v2, acq_state.is_energized, acq_state.non_energized_count,
          acq_state.quadrant, acq_state.last_step_direction,  acq_state.full_steps);
  last_isr_count = acq_state.isr_count;
  Serial.println(buffer);

  for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
    Serial.print(acq_state.buckets[i].total_ticks_in_steps);
    Serial.print(" ");
  }
  Serial.println();

  for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
    if (!acq_state.buckets[i].total_steps) {
      Serial.print(0);
    } else {
      Serial.print((uint32_t)(acq_state.buckets[i].total_step_peak_currents / acq_state.buckets[i].total_steps));
    }
    Serial.print(" ");
  }
  Serial.println();
}

static void dumpAcqCapture() {
  for (int i = 0; i < acquisition::CAPTURE_SIZE; i++) {
    acquisition::CaptureItem& item = acquisition::capture_buffer[i];
    Serial.print(-15);
    Serial.print(' ');
    Serial.print(item.v1);
    Serial.print(' ');
    Serial.print(item.v2);
    Serial.print(' ');
    Serial.println(15);
  }
}


void loop() {


  // Using static to avoid cost of repeating instantiatio.
  static acquisition::State acq_state;

  // Display
  if (millis_since_display_update >= 250) {
    millis_since_display_update = 0;
    acquisition::get_state(&acq_state);
    display::update_screen(acq_state);
    //dumpAcqState(acq_state);

    // Capture
    if (acquisition::capture_state() == acquisition::CAPTURE_READY) {
      dumpAcqCapture();
      acquisition::capture_done();
    }
  }


  // Button 1
  io::button1.update();
  if (io::button1.is_click()) {
    // Click: start capturing
    acquisition::start_capture(1);
  }
  if (io::button1.is_long_press()) {
    // Long press: zero current sensors.
    acquisition::CalibrationData calibration_data;
    acquisition::calibrate_zeros(&calibration_data);
    EEPROM.put(EEPROM_ADDRESS, calibration_data);
    Serial.print("Calibrate: ");
    Serial.print(calibration_data.offset1);
    Serial.print(' ');
    Serial.println(calibration_data.offset2);
  }

  // Button 2
  io::button2.update();
  if (io::button2.is_click()) {
    // Click: next screen
    display::next_screen();
  }
  if (io::button2.is_long_press()) {
    // Long press: reset history
    acquisition::reset_history();
  }

}
