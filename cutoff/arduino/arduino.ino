// An Arduino Pro Mini car cranking detector. 
//
// The program monitors car battery voltage via an analog input,
// looks for cranking pattern (voltage drop and then rise) and 
// when detected, activates a digital output for a short time.
// This is used to reset the bluetooth adapter in my car to 
// initiated a connection with my phone.
//
// This is useful with cars that may keep on cigarate socket power
// even after turning the ingnition off.
//

#include "timer.h"

// Units are ADC steps. 
static const int kDiffNegativeThreshold = -80;
static const int kDiffPositiveThreshold = 40;

static const int kAnalogPin = A0;    
static const int kLedPin = 13;      
static const int kBuzzerPin = 10;


static const int kBootTimeMillis = 750;
static const int kWaitTimeMillis = 4000;
static const int kActiveTimeMillis = 2000;

// NOTE: 'fp' suffix indicates 'fixed point'. The integer value
// is scaled by x 2^16.
static int16_t sample = 0;
static int32_t fast_filter_fp = 0;
static int32_t slow_filter_fp = 0;
static int16_t diff = 0;

static Timer sample_timer;
static Timer led_timer;

enum State {
  // Upon power up. Filters tracks fast to stabalie.
  STATE_BOOT,
  // Wait for voltage drop.
  STATE_IDLE,
  // Wait for voltage rise.
  STATE_WAITING_FOR_HIGH,
  // Cranking pattern detected.
  STATE_ACTIVE,
};

static State state = STATE_BOOT;
static Timer state_timer;

// Handle detectors state machines.
void detector_loop() {
  
  switch (state) {
    case STATE_BOOT:
      if (state_timer.timeMillis() > kBootTimeMillis) {
        state = STATE_IDLE;
      }
      break;

    case STATE_IDLE:
      if (diff < kDiffNegativeThreshold) {
        state = STATE_WAITING_FOR_HIGH;
        state_timer.restart();
      }
      break;

    case STATE_WAITING_FOR_HIGH:
      if (diff < kDiffNegativeThreshold) {
        state_timer.restart();
      } else if (diff > kDiffPositiveThreshold) {
        state = STATE_ACTIVE;
        state_timer.restart();
        tone(kBuzzerPin, 1000, 4000);
      } else if (state_timer.timeMillis() > kWaitTimeMillis) {
        state = STATE_IDLE;
      }
      break;

    case STATE_ACTIVE:
      if (state_timer.timeMillis() > kActiveTimeMillis) {
        state = STATE_IDLE;
        noTone(kBuzzerPin);
      }
      break;

    default:
      state = STATE_IDLE;
      noTone(kBuzzerPin);
      break;
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(kLedPin, OUTPUT);

}

// Sample VBat and apply filters.
inline void sample_loop() {
  if (sample_timer.timeMillis() < 5) {
    return;
  }
  sample_timer.restart();

  // Read input.
  sample = analogRead(kAnalogPin);

  // Convert sample input to floating point format.
  const int32_t sample_fp = ((int32_t)sample) << 16;

  // We use boot mode to stabalize filters fast on power up.
  const bool is_boot = (state == STATE_BOOT);

  // v = v + (vin - v)/16. Faster tracking in boot mode.
  fast_filter_fp += (sample_fp - fast_filter_fp) >> (is_boot ? 2 : 4);

  // v = v + (vin - v)/256. Faster tracking in boot mode.
  slow_filter_fp += (sample_fp - slow_filter_fp) >> (is_boot ? 2 : 9);  //@@@ should be 8

  // (fast_filter - slow_filter) with fp fraction removed.
  diff = (int16_t)((fast_filter_fp - slow_filter_fp) >> 16);
}

// Led control and status report.
inline void led_loop() {
  const int led_timer_millis = led_timer.timeMillis();

  const bool led_on = (state == STATE_ACTIVE)
                      || (state == STATE_WAITING_FOR_HIGH && led_timer_millis < 40)
                      || led_timer_millis < 1;

  digitalWrite(kLedPin, led_on);

  if (led_timer_millis < 100) {
    return;
  }
  led_timer.restart();

  // For debugging with the Arduino serial plotter tool
  Serial.print(sample);
  Serial.print(",");
  Serial.print((int16_t)((fast_filter_fp + 0x7fff) >> 16));
  Serial.print(",");
  Serial.print((int16_t)((slow_filter_fp + 0x7fff) >> 16));
  Serial.print(",");
  Serial.print(diff);
  Serial.print(",");
  Serial.print(state);
  Serial.println("00");  // for serial plotter
}

// Main loop
void loop() {
  // Sample VBat and apply filters.
  sample_loop();
  
  // Handle detection FSM.
  detector_loop();

  // LED control and status report.
  led_loop();
}
