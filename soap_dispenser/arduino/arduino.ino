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

// TODO: add current sensing functionality. Rotate the motor
// in reverse back to parking position and indicate error on LED.

// TODO: experiment with more granular soap dispensing. E.g. do
// one and a half rotation and move in reverse to parking.

// TODO: improve error indication on LEDs (e.g. for a timeout
// during a dispensing cycle).


//=================== Motor =========================

namespace sensors {

static const byte DOOR_OPENED_IN = 24;
static const byte PROXIMITY_IN   = 25;
static const byte PARKING_IN     = 26;

inline boolean is_door_opened() {
  return digitalRead(DOOR_OPENED_IN);
}

inline boolean is_door_closed() {
  return !digitalRead(DOOR_OPENED_IN);
}

inline boolean is_in_parking() {
  return digitalRead(PARKING_IN);
}

inline boolean is_proximity_on() {
  return digitalRead(PROXIMITY_IN);
}

inline boolean is_proximity_off() {
  return !digitalRead(PROXIMITY_IN);
}

inline void setup() {
  // Initialize inputs. We use external pullups when needed and don't
  // waste energey on internal pullups.
  pinMode(DOOR_OPENED_IN, INPUT);
  pinMode(PROXIMITY_IN, INPUT);
  pinMode(PARKING_IN, INPUT);
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

// LED control Arduino digital outputs. Active low.
//#define YELLOW_LED_PIN 10
//#define RED_LED_PIN     9

namespace led {
static const byte YELLOW_LED_PIN = 10;
static const byte RED_LED_PIN    =  9;

static void off() {
  digitalWrite(RED_LED_PIN, HIGH);
  digitalWrite(YELLOW_LED_PIN, HIGH);
}

static void red() {
  digitalWrite(RED_LED_PIN, LOW);
  digitalWrite(YELLOW_LED_PIN, HIGH);
}

static void yellow() {
  digitalWrite(RED_LED_PIN, HIGH);
  digitalWrite(YELLOW_LED_PIN, LOW);
}

static void green() {
  digitalWrite(RED_LED_PIN, LOW);
  digitalWrite(YELLOW_LED_PIN, LOW);
}

static inline void setup() {
  led::off();
  pinMode(RED_LED_PIN, OUTPUT);
  pinMode(YELLOW_LED_PIN, OUTPUT);
}
}  // namespace led


//=================== Timer ========================

namespace timer {

static uint32_t start_time_millis;

inline void reset() {
  start_time_millis = millis();
}

inline uint32_t elapsed_millis()  {
  return millis() - start_time_millis;
}
}  // namespace timer


//=================== Main =========================


void run_one_cycle() {

  // Start motor forward
  motor::forward();

  // Wait for exit from PARKING state, with timeout.
  timer::reset();
  while (sensors::is_in_parking()) {
    if (timer::elapsed_millis() > 1000) {
      motor::off();
      return;
    }
  }

  // Wait past the parking switch bounce..
  delay(10);

  // Wait for entering back the PARKING state, after one revolution.
  // With timeout.
  // TODO: add debouncing on the parking switch.
  timer::reset;
  while (!sensors::is_in_parking()) {
    if (timer::elapsed_millis() > 1000) {
      motor::off();
      return;
    }
  }

  // Short motor to accelerate stopping.
  motor::brake();
  delay(50);

  // All done
  motor::off();
}

void setup() {
  timer::reset();
  motor::setup();
  led::setup();
  sensors::setup();
}

void loop() {
  boolean blink_state = false;

  //if (sensors::is_proximity_on) {
  if (sensors::is_door_closed()) {
    led::red();
    run_one_cycle();
    return;
  }

  blink_state = !blink_state;
  blink_state ? led::red() : led::off();
}
