// Stepper analyzer.
// Designed for Teensy 4.0.
//
// Board: teensy 4.0
// Optimizer: faster
//

//#include "display.h"
#include "acquisition.h"
#include "simple_string.h"
#include "io.h"
#include <string.h>
#include <stdio.h>
#include <elapsedMillis.h>
#include <EEPROM.h>

#define NEXTION Serial5

static elapsedMillis millis_since_display_update;

struct EepromData {
  int offset1;
  int offset2;
};

static char buffer[300];


SimpleString<50> line;


// EEPROM address for storing configuration. This is an arbitrary value.
static const uint32_t EEPROM_ADDRESS = 16;



static acquisition::State acq_state;


//static bool capture_pending;
//static acquisition::CaptureBuffer capture_buffer;
//static bool capture_changed = true;


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




static void calibrate_zeros() {
    acquisition::CalibrationData calibration_data;
    acquisition::calibrate_zeros(&calibration_data);
    EEPROM.put(EEPROM_ADDRESS, calibration_data);
    Serial.print("Calibrate: ");
    Serial.print(calibration_data.offset1);
    Serial.print(' ');
    Serial.println(calibration_data.offset2);
}

// 'line' contains a non empty line from Nextion. Process it.
static void process_line() {
  if (line.equals("#RST")) {
    acquisition::reset_history();
    Serial.println("Reset history");
    return;
  }

  if (line.equals("#ZRO")) {
    calibrate_zeros();
    Serial.println("Zero");
    return;
  }

  Serial.println("*** UNKNOWN LINE, ignored.");
}

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
  if (millis_since_display_update >= 100) {
    millis_since_display_update = 0;
    //io::set_led2();
    update_display();
    //io::reset_led2();
  }

  while (NEXTION.available()) {
    char c = char(NEXTION.read());
    if (c != '\n' && c != '\r') {
      if (!line.full()) {
        sprintf(buffer, "* %02x '%c'",  c, c);
        Serial.println(buffer);
        line.add(c);
      }
    } else {
      if (!line.isEmpty()) {
        Serial.println(line.c_str());
        if (line.full()) {
          Serial.println("Line buffer is full. Ignoring.");
        } else {
          process_line();
        }
        line.clear();
        Serial.println("cleared");
        // One line at most in a loop();
        break;
      }
    }
  }
}
