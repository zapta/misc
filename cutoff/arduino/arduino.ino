#include "timer.h"

static const int threshold = 70;

static const int analog_pin = A0;    // select the input pin for the potentiometer
static const int led_pin = 13;      // select the pin for the LED

// NOTE: 'fp' suffix indicates 'fixed point'. The integer value
// is scaled by x 2^16.
static int16_t sample = 0;
static int32_t fast_filter_fp = 0;
static int32_t slow_filter_fp = 0;
static int16_t diff = 0;

static Timer sample_timer;
static Timer led_timer;

enum State {
  STATE_IDLE = 0,
  STATE_WAITING_FOR_HIGH = 1,
  STATE_ACTIVE = 2,
};

static State state = STATE_IDLE;
static Timer state_timer;

void detector_loop() {
  switch (state) {
    
    case STATE_IDLE:
      if (diff < -threshold) {
        Serial.print("0.1: ");
        Serial.println(diff);
        state = STATE_WAITING_FOR_HIGH;
        state_timer.restart();
      }
      break;
      
    case STATE_WAITING_FOR_HIGH:
      if (diff < -threshold) {
        Serial.print("1.1:");
        Serial.println(diff);
        state_timer.restart();
      } else if (diff > threshold) {
        Serial.print("1.2:");
        Serial.println(diff);
        state = STATE_ACTIVE;
        state_timer.restart();
      } else if (state_timer.timeMillis() > 5000) {
        Serial.println("1.3");
        state = STATE_IDLE;
      }
      break;
      
    case STATE_ACTIVE:
      if (state_timer.timeMillis() > 1000) {
        Serial.println("2.1");
        state = STATE_IDLE;
      }
      break;
      
    default:
      state = STATE_IDLE;
      break;
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(led_pin, OUTPUT);
}

inline void sample_loop() {
  if (sample_timer.timeMillis() < 5) {
    return;
  }
  sample_timer.restart();

  // Read input.
  sample = analogRead(analog_pin);
  const int32_t sample_fp = ((int32_t)sample) << 16;

  // v = v + (vin - v)/16
  fast_filter_fp += (sample_fp - fast_filter_fp) >> 4;

  // v = v + (vin - v)/256
  slow_filter_fp += (sample_fp - slow_filter_fp) >> 8;

  diff = (int16_t)((fast_filter_fp - slow_filter_fp) >> 16);
}

inline void led_loop() {
  const int led_timer_millis = led_timer.timeMillis();
  const bool led_on = (state == STATE_ACTIVE || led_timer_millis < 40);
  digitalWrite(led_pin, led_on);
  
  if (led_timer_millis < 300) {
    return;
  }
  led_timer.restart();

  Serial.print(sample);
  Serial.print(", ");
  Serial.print(diff);
  Serial.print(", ");
  Serial.println(state);
}

void loop() {
  sample_loop();
  detector_loop();
  led_loop();
}
