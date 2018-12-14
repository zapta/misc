#include <avr/sleep.h>
//#include <avr/interrupt.h>
//#include <avr/pgmspace.h>
#include <Arduino.h>

// Soap dispenser Arduino firmware.

// ATtiny48 Arduin support from
// https://github.com/SpenceKonde/ATTinyCore/blob/master/avr/extras/ATtiny_x8.md

// Arduino IDE 1.8.5 configuraiton (Tools menu)
// --------------------------------------------
// Board: ATtiny48/88
// Chip: Attiny48
// Clock: 1 MHZ (internal)
// Save EEPROM: EEPROM retained
// LTO: Enabled
// BOD Level: B.O.D Enabled (2.7V)

// TODO: implement sleep mode.

// TODO: add current sensing functionality. Rotate the motor
// in reverse back to parking position and indicate error on LED.

// TODO: experiment with more granular soap dispensing. E.g. do
// one and a half rotation and move in reverse to parking.

// TODO: improve error indication on LEDs (e.g. for a timeout
// during a dispensing cycle).


class Timer {
  public:
    Timer() {
      start_time_millis = millis();
    }

    inline void reset() {
      start_time_millis = millis();
    }

    inline uint32_t elapsed_millis()  {
      return millis() - start_time_millis;
    }

  private:
    uint32_t start_time_millis;
};


//=================== Diagnostics ===================

namespace diag {

static boolean _had_errors = false;

static inline void set_error() {
  _had_errors = true;
}

static inline void clear_error() {
  _had_errors = false;
}

static inline boolean had_error() {
  return _had_errors;
}

}  // namespace diag;


//=================== Motor =========================

namespace sensors {

// Input pins. Active high unless specificed otherwise.
static const byte DOOR_OPENED_PIN = 24;
static const byte PROXIMITY_PIN   = 25;
static const byte PARKING_PIN     = 26;

inline boolean is_door_opened() {
  return digitalRead(DOOR_OPENED_PIN);
}

inline boolean is_door_closed() {
  return !digitalRead(DOOR_OPENED_PIN);
}

inline boolean is_in_parking() {
  return digitalRead(PARKING_PIN);
}

static boolean old_proximity_state;

inline boolean is_proximity_trigger() {
  boolean temp = old_proximity_state;
  old_proximity_state = digitalRead(PROXIMITY_PIN);
  return old_proximity_state && !temp;
}

inline void setup() {
  // Initialize inputs. We use external pullups when needed and don't
  // waste energey on internal pullups.
  pinMode(DOOR_OPENED_PIN, INPUT);
  pinMode(PROXIMITY_PIN, INPUT);
  pinMode(PARKING_PIN, INPUT);
}
}  // namespace sensors


//=================== Motor =========================

namespace motor {
// Motor control Arduino digital outputs. Active high.
static const byte X1_PIN  =  2;
static const byte X2_PIN  =  1;
static const byte Y1_PIN  =  3;
static const byte Y2_PIN  = 15;

static inline void switch_delay() {
  delayMicroseconds(50);
}

static inline void off() {
  digitalWrite(X1_PIN, LOW);
  digitalWrite(X2_PIN, LOW);
  digitalWrite(Y1_PIN, LOW);
  digitalWrite(Y2_PIN, LOW);
}

static inline void forward() {
  digitalWrite(X2_PIN, LOW);
  digitalWrite(Y1_PIN, LOW);
  switch_delay();
  digitalWrite(X1_PIN, HIGH);
  digitalWrite(Y2_PIN, HIGH);
}

static inline void backward() {
  digitalWrite(X1_PIN, LOW);
  digitalWrite(Y2_PIN, LOW);
  switch_delay();
  digitalWrite(X2_PIN, HIGH);
  digitalWrite(Y1_PIN, HIGH);
}

static inline void brake() {
  digitalWrite(X2_PIN, LOW);
  digitalWrite(Y2_PIN, LOW);
  switch_delay();
  digitalWrite(X1_PIN, HIGH);
  digitalWrite(Y1_PIN, HIGH);
}

static inline void setup() {
  motor::off();
  pinMode(X1_PIN, OUTPUT);
  pinMode(X2_PIN, OUTPUT);
  pinMode(Y1_PIN, OUTPUT);
  pinMode(Y2_PIN, OUTPUT);
}
}  // namespace motor

//=================== LED =========================

namespace led {
// Both pins are active low.
static const byte RED_LED_PIN   =  9;
static const byte GREEN_LED_PIN = 10;

static void off() {
  digitalWrite(RED_LED_PIN, HIGH);
  digitalWrite(GREEN_LED_PIN, HIGH);
}

static void red() {
  digitalWrite(RED_LED_PIN, LOW);
  digitalWrite(GREEN_LED_PIN, HIGH);
}

static void yellow() {
  digitalWrite(RED_LED_PIN, LOW);
  digitalWrite(GREEN_LED_PIN, LOW);
}

static void green() {
  digitalWrite(RED_LED_PIN, HIGH);
  digitalWrite(GREEN_LED_PIN, LOW);
}

static inline void setup() {
  led::off();
  pinMode(RED_LED_PIN, OUTPUT);
  pinMode(GREEN_LED_PIN, OUTPUT);
}
}  // namespace led

//=================== Main =========================

void dispense_once() {
  static Timer action_timer;

  // Start motor forward
  motor::forward();

  // Wait for exit from PARKING state, with timeout.
  action_timer.reset();
  while (sensors::is_in_parking()) {
    if (action_timer.elapsed_millis() > 1000) {
      motor::off();
      diag::set_error();
      return;
    }
  }

  // Wait past the parking switch bounce..
  delay(10);

  // Wait for entering back the PARKING state, after one revolution.
  // With timeout.
  // TODO: add debouncing on the parking switch.
  action_timer.reset();
  while (!sensors::is_in_parking()) {
    if (action_timer.elapsed_millis() > 1000) {
      motor::off();
      diag::set_error();
      return;
    }
  }

  // Short motor to accelerate stopping.
  motor::brake();
  delay(50);

  // All done
  motor::off();
}

static volatile boolean proximity_active = false;

// Interrupt handler for any changes in the 4 sense inputs.
// This also wakes up the CPU if in sleep mode.
ISR(PCINT3_vect)
{
  if (digitalRead(sensors::PROXIMITY_PIN)) {
    proximity_active = true;
  }
}


void setup() {
  motor::setup();
  led::setup();
  sensors::setup();

  PCMSK3 |= (1 << PCINT26);
  PCICR |= (1 << PCIE3);

  // This prevents spurious activation on power up.
  // TODO: what causes this activation?
  led::green();
  delay(2000);
  led::off();
  proximity_active = false;
}

// Base on this article
// http://www.engblaze.com/hush-little-microprocessor-avr-and-arduino-sleep-mode-basics/
void sleep_now() {
  // Choose our preferred sleep mode:
  set_sleep_mode(SLEEP_MODE_PWR_DOWN);
  // Set sleep enable (SE) bit:
  sleep_enable();
  // Put the device to sleep:
  sleep_mode();
  // Upon waking up, sketch continues from this point.
  sleep_disable();
}

Timer proxmity_timer;
void loop() {
  sleep_now();

  if (proximity_active) {
    //blink_state = !blink_state;
    led::green();
    dispense_once();
    led::off();
    proximity_active = false;
  }
}

