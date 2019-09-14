#include <avr/sleep.h>
#include <Arduino.h>

// Arduino Firmware for GOJO LTX-7 Soap Dispenser

// ATtiny48 Arduino core from
// https://github.com/SpenceKonde/ATTinyCore/blob/master/avr/extras/ATtiny_x8.md

// Arduino IDE 1.8.5 configuraiton (Tools menu)
// --------------------------------------------
// Board: ATtiny48/88
// Chip: Attiny48
// Clock: 1 MHZ (internal)
// Save EEPROM: EEPROM retained
// LTO: Enabled
// BOD Level: B.O.D Enabled (2.7V)

// TODO: add current sensing functionality. Rotate the motor
// in reverse back to parking position and indicate error on LED.

// TODO: experiment with more granular soap dispensing. E.g. do
// one and a half rotation and move in reverse to parking.

// TODO: improve error indication on LEDs (e.g. for a timeout
// during a dispensing cycle).

// Number of motor's cycles per activation. 
#define STROKES_PER_ACTIVATION 1

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


//=================== sensors ======================

namespace sensors {

// Input pins. Active high unless specificed otherwise.
static const byte DOOR_OPENED_PIN = 24;  // PA1
static const byte PROXIMITY_PIN   = 25;  // PA2
static const byte PARKING_PIN     = 26;  // PA3

inline boolean is_door_opened() {
  return digitalRead(DOOR_OPENED_PIN);
}

inline boolean is_door_closed() {
  return !digitalRead(DOOR_OPENED_PIN);
}

inline boolean is_in_parking() {
  return digitalRead(PARKING_PIN);
}

static volatile boolean proximity_event = false;

// Interrupt handler for any changes in the 4 sense inputs.
// This also wakes up the CPU if in sleep mode.
ISR(PCINT3_vect)
{
  if (digitalRead(sensors::PROXIMITY_PIN)) {
    proximity_event = true;
  }
}

inline void setup() {
  // Initialize inputs. We use external pullups when needed and don't
  // waste energey on internal pullups.
  pinMode(DOOR_OPENED_PIN, INPUT);
  pinMode(PROXIMITY_PIN, INPUT);
  pinMode(PARKING_PIN, INPUT);

  // This enables the on-change interrupts for MCU inputs PA0, PA1, PA2, PA3.
  // When any of these inputs changes state, the ISR above for PCINT3_vect
  // is called.
  PCMSK3 |= (1 << PCINT26);
  PCICR |= (1 << PCIE3);
}
}  // namespace sensors


//=================== Motor =========================

namespace motor {
// Motor control Arduino digital outputs. Active high.
static const byte X1_PIN  =  2; // PD2
static const byte X2_PIN  =  1; // PD1
static const byte Y1_PIN  =  3; // PD3
static const byte Y2_PIN  = 15; // PB7

// A short delay to let power mosefet time to change state
// from on to off. We inset it before turning any mosfet on to
// avoid direct path from +6V to ground.
static inline void mosfet_delay() {
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
  mosfet_delay();
  digitalWrite(X1_PIN, HIGH);
  digitalWrite(Y2_PIN, HIGH);
}

static inline void backward() {
  digitalWrite(X1_PIN, LOW);
  digitalWrite(Y2_PIN, LOW);
  mosfet_delay();
  digitalWrite(X2_PIN, HIGH);
  digitalWrite(Y1_PIN, HIGH);
}

// This short the motor for faster stop.
static inline void brake() {
  digitalWrite(X2_PIN, LOW);
  digitalWrite(Y2_PIN, LOW);
  mosfet_delay();
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
static const byte RED_LED_PIN   =  9; // PB1
static const byte GREEN_LED_PIN = 10; // PB2

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

// Performs STROKES_PER_ACTIVATION consecutive strokes.
void dispense() {
  static Timer timer;

  // Not likely but may be useful during debugging.
  if (STROKES_PER_ACTIVATION < 0) {
    return;
  }

  // Start motor forward.
  motor::forward();

  for (int i = 0; i < STROKES_PER_ACTIVATION; i++) {
    // Let the parking switch stabalize from previous loop (debouncing).
    delay(10);

    // Wait for exit from PARKING state, with sanity check timeout.
    timer.reset();
    while (sensors::is_in_parking()) {
      if (timer.elapsed_millis() > 1000) {
        motor::off();
        diag::set_error();
        return;
      }
    }

    // Wait for the parking switch to stablize in the non parking
    // state (debouncing).
    delay(10);

    // Wait for entering back the PARKING region, after one
    // full revolution. With sanity check timeout.
    timer.reset();
    while (!sensors::is_in_parking()) {
      if (timer.elapsed_millis() > 1000) {
        motor::off();
        diag::set_error();
        return;
      }
    }
  }

  // Short the motor to reduce stopping time. Otherwise it continues
  // quite a lot from inertia.
  motor::brake();
  delay(50);

  // All done
  motor::off();
}

void setup() {
  motor::setup();
  led::setup();
  sensors::setup();

  // This prevents spurious activation on power up.
  // TODO: what causes this activation?
  led::green();
  delay(2000);
  led::off();
  sensors::proximity_event = false;
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

void loop() {
  // This put the MCU to sleep until any of the sensor inputs changes
  // state and activates the interrupt routine.
  sleep_now();

  if (sensors::proximity_event) {
    if (sensors::is_door_closed()) {
      led::green();
      dispense();
      led::off();
    } else {
      led::red();
      delay(400);
      led::off();
    }
    // Clear any pending event.
    sensors::proximity_event = false;
  }
}

