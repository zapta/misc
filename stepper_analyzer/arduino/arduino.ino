// Stepper analyzer.
// Designed for Teensy 4.0.
//
// Board: teensy 4.0
// Optimizer: faster
//

//#include "display.h"
#include "acquisition.h"
#include "static_string.h"
#include "io.h"
#include <string.h>
#include <stdio.h>
#include <elapsedMillis.h>
#include <EEPROM.h>

#define NEXTION Serial5

// Page 1 fields
#define P1_AMPS_A "t4.txt"
#define P1_AMPS_B "t5.txt"
#define P1_ERRORS "t6.txt"
#define P1_POWER "t7.txt"
#define P1_IDLES "t9.txt"
#define P1_STEPS "t11.txt"

// Page 2 fields
#define P2_STEPS "t11.txt"

// Page 5 fields
#define P5_SPEED "t9.txt"
#define P5_STEPS "t11.txt"
#define P5_DIAL  "z0.val"

// Page 9 fields
#define P9_AMPS_A "t4.txt"
#define P9_AMPS_B "t5.txt"



// https://github.com/pfeerick/elapsedMillis/blob/master/elapsedMillis.h
static elapsedMillis millis_since_display_update;

struct EepromData {
  int offset1;
  int offset2;
};

static char buffer[300];


StaticString<50> line;

// Index of current display handler in handlers[].
int handler_index = 0;

int waveform_offset = 0;

// EEPROM address for storing configuration. This is an arbitrary value.
static const uint32_t EEPROM_ADDRESS = 16;

static acquisition::State acq_state;

static void send_cmd(const char* command) {
  NEXTION.print(command);
  NEXTION.print("\xff\xff\xff");
}

void send_field(const char* field, const char* value) {
  NEXTION.print(field);
  NEXTION.print("=\"");
  NEXTION.print(value);
  NEXTION.print("\"\xff\xff\xff");
}

void send_field(const char* field, int value) {
  NEXTION.print(field);
  NEXTION.print("=\"");
  NEXTION.print(value);
  NEXTION.print("\"\xff\xff\xff");
}

void send_field(const char* field, const char* format, float value) {
  static const int kBufferSize = 20;
  static char text_buffer[kBufferSize];
  snprintf(text_buffer, kBufferSize, format, value);
  send_field(field, text_buffer);
}

class PageHandler {
  public:
    // Passed in 'code' should be valid through the lifetime of this object.
    PageHandler(int desired_rate_millis, const char* code) : desired_rate_millis_(desired_rate_millis), code_(code)  {}
    virtual void enter() {}
    virtual void leave() {}
    virtual void update_display() {}
    virtual void process_line() {}
    const int desired_rate_millis_;
    const char* const code_;
};

class Page1Handler : public PageHandler {
  public:
    Page1Handler() : PageHandler(100, "#PG1") {}

    void update_display() override {
      acquisition::get_state(&acq_state);
      send_field(P1_AMPS_A, "%6.2f", acquisition::adc_value_to_amps(acq_state.display_v1));
      send_field(P1_AMPS_B, "%6.2f", acquisition::adc_value_to_amps(acq_state.display_v2));
      send_field(P1_ERRORS,  acq_state.quadrature_errors);
      send_field(P1_POWER, acq_state.is_energized ? " ON" : "OFF");
      send_field(P1_IDLES, acq_state.non_energized_count);
      send_field(P1_STEPS, acq_state.full_steps);
    }
};


class Page2Handler : public PageHandler {
  public:
    Page2Handler() : PageHandler(20, "#PG2") {}
    void update_display() override {
      //Serial.println("P2");
      // Get acquisition state.
      acquisition::get_state(&acq_state);

      // Adjust for graph over/under flow
      const int val = acq_state.full_steps;
      const int val10 = val / 10;
      if (waveform_offset + val10 > 120) {
        waveform_offset = -val10 - 100;
        send_cmd("cle 1,0");
      } else if (waveform_offset + val10 < -120) {
        waveform_offset = -val10 + 100;
        send_cmd("cle 1,0");
      }

      // Add the graph data point.
      const int v2 =  128 + waveform_offset + val10;
      sprintf(buffer, "add 1,0,%d", v2);
      send_cmd(buffer);
      //Serial.println(buffer);
      send_field(P2_STEPS,  acq_state.full_steps);

    }
};

class Page3Handler : public PageHandler {
  public:
    Page3Handler() : PageHandler(500, "#PG3") {}
    void update_display() override {
      acquisition::get_state(&acq_state);
      // Find max ticks in step.
      uint32_t max_ticks_in_step = 0;
      for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
        const uint32_t ticks_in_step = acq_state.buckets[i].total_ticks_in_steps;
        if (ticks_in_step > max_ticks_in_step) {
          max_ticks_in_step = ticks_in_step;
        }
      }
      // Send buckets to display
      for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
        const uint32_t ticks_in_step = acq_state.buckets[i].total_ticks_in_steps;
        int percents = 0;
        if (max_ticks_in_step > 0) {
          percents = (100 * ticks_in_step) / max_ticks_in_step;
        }
        percents = max(1, percents);
        sprintf(buffer, "h%d.val=%d", i, percents);
        send_cmd(buffer);
      }

    }
};

class Page4Handler : public PageHandler {
  public:
    Page4Handler() : PageHandler(500, "#PG4") {}
    void update_display() override {
      acquisition::get_state(&acq_state);
      // Send buckets to display.
      for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
        const acquisition::HistogramBucket& bucket = acq_state.buckets[i];
        const int milliamps =  (bucket.total_steps == 0)
                               ? 0
                               : acquisition::adc_value_to_milliamps(
                                 bucket.total_step_peak_currents / bucket.total_steps);
        int percents = (100 * milliamps) / acquisition::MAX_MILLIAMPS;
        percents = max(1, percents);
        percents = min(100, percents);
        //percents = 70 + i;
        Serial.println(percents);
        sprintf(buffer, "h%d.val=%d", i, percents);
        send_cmd(buffer);
      }

    }
};

class Page5Handler : public PageHandler {
  public:
    Page5Handler() : PageHandler(25, "#PG5") {}
    void enter() override {
      state_ = kNotUpdated;
    }
    void update_display() override {
      acquisition::get_state(&acq_state);
      send_field(P5_STEPS, acq_state.full_steps);
      const unsigned long current_millis = millis();
      // If we don't have the previous reading, we can't compute speed.
      if (state_ != kNotUpdated) {
        const int delta_millis = current_millis - last_millis_;
        const int delta_steps = abs(acq_state.full_steps - last_full_steps_);
        int steps_per_sec = delta_millis
                            ? (delta_steps * 1000) / delta_millis
                            : 0;
        // Update speed field only if changed, to reduce flicker.
        if (state_ == kUpdatedOnce || steps_per_sec != last_displayed_steps_per_sec_) {
          send_field(P5_SPEED, steps_per_sec);
          last_displayed_steps_per_sec_ = steps_per_sec;
        }
        int angle = (steps_per_sec * 270) / 2000;  // 2000 steps/sec is max.
        angle = min(270, angle);  // clip to 270.
        // Dial has a -45 offset and accepts only positive angles.
        angle = (angle >= 45)
                ? angle - 45
                : angle - 45 + 360;
        // Update dial only if changed, to reduce flicker.
        if (state_ == kUpdatedOnce || angle != last_displayed_angle_) {
          sprintf(buffer, "%s=%d", P5_DIAL, angle);
          send_cmd(buffer);
          last_displayed_angle_ = angle;
        }

      }

      // Increment state.
      if (state_ == kNotUpdated) {
        state_ = kUpdatedOnce;
      } else if (state_ == kUpdatedOnce) {
        state_ = kStable;
      }

      last_millis_ = current_millis;
      last_full_steps_ = acq_state.full_steps;
    }

  private:
    enum State { kNotUpdated, kUpdatedOnce, kStable};
    State state_;
    // These are available when stage_ >= kUpdateOnce.
    unsigned long last_millis_ = 0;
    int last_full_steps_ = 0;
    // These are available when stage_ == kStable.
    int last_displayed_steps_per_sec_ = 0;
    int last_displayed_angle_ = 0;
};

// Setup page
class Page9Handler : public PageHandler {
  public:
    Page9Handler() : PageHandler(100, "#PG9") {}

    void update_display() override {
      acquisition::get_state(&acq_state);
      send_field(P1_AMPS_A, "%6.2f", acquisition::adc_value_to_amps(acq_state.display_v1));
      send_field(P1_AMPS_B, "%6.2f", acquisition::adc_value_to_amps(acq_state.display_v2));
    }

    void process_line() override {
      Serial.printf("P9: %s\n", line.c_str());
      // Handle ADC zero calibration.
      if (line.equals("#ZRO")) {
        acquisition::CalibrationData calibration_data;
        acquisition::calibrate_zeros(&calibration_data);
        EEPROM.put(EEPROM_ADDRESS, calibration_data);
        Serial.print("Calibrate: ");
        Serial.print(calibration_data.offset1);
        Serial.print(' ');
        Serial.println(calibration_data.offset2);
      }
      // Handle direction change.
    }

};

// Handlers table.
static Page1Handler page1_handler;
static Page2Handler page2_handler;
static Page3Handler page3_handler;
static Page4Handler page4_handler;
static Page5Handler page5_handler;
static Page9Handler page9_handler;

PageHandler* handlers[] = {
  &page1_handler, &page2_handler, &page3_handler, &page4_handler, &page5_handler, &page9_handler
};

static const int kNumHandlers = sizeof(handlers) / sizeof(handlers[0]);



static void set_page_handler_index(int new_handler_index) {
  Serial.print("page index -> ");
  Serial.println(new_handler_index);
  handlers[handler_index]->leave();
  handler_index = new_handler_index;
  handlers[handler_index]->enter();
  return;

}

// TODO: have the page selectors an attribute of the ahdnelrs.
// 'line' contains a non empty line from Nextion. Process it.
static void process_line() {
  for (int i = 0; i < kNumHandlers; i++) {
    if (line.equals(handlers[i]->code_)) {
      set_page_handler_index(i);
      return;
    }
  }

  // Reset the acquistion buffers
  if (line.equals("#RST")) {
    acquisition::reset_history();
    Serial.println("Reset history");
  }

  handlers[handler_index]->process_line();
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

  handlers[handler_index]->enter();
  send_cmd("page 0");

  // Force display update on start
  millis_since_display_update = 999999;
}


void loop() {
  // Display
  const unsigned int ms_rate = handlers[handler_index]->desired_rate_millis_;
  if (millis_since_display_update >= ms_rate) {
    //Serial.printf("h=%d\n", handler_index);
    millis_since_display_update = 0;
    handlers[handler_index]->update_display();
    //Serial.printf("Display: %d ms\n",  (int)millis_since_display_update);
  }

  while (NEXTION.available()) {
    char c = char(NEXTION.read());
    if (c != '\n' && c != '\r') {
      if (!line.is_full()) {
        line.add(c);
        // Nextion status message
        if (line.ends_with("\xff\xff\xff")) {
          //process_msg();
          line.clear();
        }
      }
    } else {
      // Line terminator
      if (!line.is_empty()) {
        Serial.println(line.c_str());
        if (line.is_full()) {
          Serial.println("Line buffer is full. Ignoring.");
        } else {
          process_line();
        }
        line.clear();
        // One line at most in a loop();
        break;
      }
    }
  }
}
