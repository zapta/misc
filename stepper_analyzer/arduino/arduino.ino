// Stepper analyzer.
// Designed for Teensy 4.0.
//
// Board: teensy 4.0
// Optimizer: faster
//

//#include "display.h"
#include "acquisition.h"
#include "io.h"
#include <string.h>
#include <stdio.h>
#include <elapsedMillis.h>
#include <EEPROM.h>

#define NEXTION Serial2

static elapsedMillis millis_since_display_update;

struct EepromData {
  int offset1;
  int offset2;
};

static char buffer[300];


// EEPROM address for storing configuration. This is an arbitrary value.
static const uint32_t EEPROM_ADDRESS = 16;

//static int screen_num = 0;
//static bool full_redraw = true;

static acquisition::State acq_state;

//static int screen_updates_since_last_capture;

//static bool capture_pending;
//static acquisition::CaptureBuffer capture_buffer;
//static bool capture_changed = true;


//static void next_screen() {
//  if (screen_num >= 0 && screen_num < 3) {
//    screen_num++;
//  } else {
//    screen_num = 0;
//  }
//  if (screen_num == 3) {
//    // Large to force immediate capture
//    screen_updates_since_last_capture = 9999;
//  }
//  full_redraw = true;
//}


//static int last_full_steps = 0;

static void send(const char* msg) {
  //Serial.println(msg);
  NEXTION.print(msg);
  NEXTION.print("\xff\xff\xff");
}

static void update_display() {
  //io::toggle_led2();
  acquisition::get_state(&acq_state);

  sprintf(buffer, "t4.txt=\"%6.2f\"",  acquisition::adc_value_to_amps(acq_state.display_v1));
  send(buffer);

  sprintf(buffer, "t5.txt=\"%6.2f\"",  acquisition::adc_value_to_amps(acq_state.display_v2));
  send(buffer);

  sprintf(buffer, "t6.txt=\"%6lu\"", acq_state.quadrature_errors);
  send(buffer);

  sprintf(buffer, "t7.txt=\"%s\"",  acq_state.is_energized ? " ON" : "OFF");
  send(buffer);

  sprintf(buffer, "t9.txt=\"%6lu\"",  acq_state.non_energized_count);
  send(buffer);

  sprintf(buffer, "t11.txt=\"%d\"", acq_state.full_steps);
  send(buffer);

}

//static void update_display() {
//  switch (screen_num) {
//    case 0:
//      acquisition::get_state(&acq_state);
//
//      Serial.println(acq_state.full_steps - last_full_steps);
//      last_full_steps = acq_state.full_steps;
//
//      acquisition::dump_state(acq_state);
//      display::draw_info_screen(acq_state, full_redraw);
//      break;
//
//    case 1:
//      acquisition::get_state(&acq_state);
//      display::draw_time_histogram_screen(acq_state, full_redraw);
//      break;
//
//    case 2:
//      acquisition::get_state(&acq_state);
//      display::draw_amps_histogram_screen(acq_state, full_redraw);
//      break;
//
//    case 3:
//        if (screen_updates_since_last_capture > 12  && acquisition::is_capture_ready()) {
//           screen_updates_since_last_capture  = 0;
//           acquisition::start_capture(48);
//           capture_pending = true;
//        }
//        screen_updates_since_last_capture++;
//       // acquisition::get_capture(&capture_buffer);
//        display::draw_signals_screen(capture_buffer, full_redraw || capture_changed);
//        capture_changed = false;
//     // }
//      break;
//  }
//  full_redraw = false;
//}

//static void calibrate_zeros() {
//    acquisition::CalibrationData calibration_data;
//    acquisition::calibrate_zeros(&calibration_data);
//    EEPROM.put(EEPROM_ADDRESS, calibration_data);
//    Serial.print("Calibrate: ");
//    Serial.print(calibration_data.offset1);
//    Serial.print(' ');
//    Serial.println(calibration_data.offset2);
//}


void setup() {
  Serial.begin(9600);
  NEXTION.begin(115200);


  io::setup();

  acquisition::CalibrationData calibration_data;
  EEPROM.get(EEPROM_ADDRESS, calibration_data);
  Serial.println();
  Serial.print("Calibration data: ");
  Serial.print(calibration_data.offset1);
  Serial.print(' ');
  Serial.println(calibration_data.offset2);
  acquisition::setup(calibration_data);

  //  display::setup();

  // Force display update on start
  millis_since_display_update = 999999;
}




void loop() {


  // Display
  if (millis_since_display_update >= 1                                     00) {
    millis_since_display_update = 0;
    io::set_led2();
    update_display();
    io::reset_led2();

  }
  //
  //  if (millis_since_display_update >= 15) {
  //    millis_since_display_update = 0;
  //    update_display();
  //    sprintf(buffer, "Switches: %d %d %d %d",
  //      io::dip_switch1(),  io::dip_switch2(),  io::dip_switch3(),  io::dip_switch4());
  //      Serial.println(buffer);
  //  }

  //  if (capture_pending && acquisition::is_capture_ready()) {
  //    Serial.println("CAPTURE READY");
  //    acquisition::get_capture(&capture_buffer);
  //    //acquisition::dump_capture(capture_buffer);
  //    //screen_updates_since_last_capture = 0;
  //
  //    capture_pending = false;
  //    capture_changed = true;
  //  }

  //  // Button 1
  //  io::button1.update();
  //  if (io::button1.is_click()) {
  //    // Click: start capturing
  //    acquisition::start_capture(4);
  //    capture_pending = true;
  //  }
  //  if (io::button1.is_long_press()) {
  //    // Long press: zero current sensors.
  //    calibrate_zeros();
  //  }

  //  // Button 2
  //  io::button2.update();
  //  if (io::button2.is_click()) {
  //    // Click: next screen
  //    next_screen();
  //  }
  //  if (io::button2.is_long_press()) {
  //    // Long press: reset history
  //    acquisition::reset_history();
  //  }
}
