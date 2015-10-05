// Controller the solder paste injector.

// For motor pin connection see motor_io.cpp.

#include "motor.h"

// Finite state machine states. Using 8bit enums.
namespace states {
  // Not moving, motor is on.
  static const uint8_t IDLE = 0;
  // Moving forward as long as the forward button is pressed.
  // Speed is controlled by the potentiometer.
  static const uint8_t FORWARD = 1;
  // Moving backward at a fast speed as long as the Backward button
  // is pressed.
  static const uint8_t BACKWARD = 3;
  // Same as IDLE but motor coils are not energized.
  static const uint8_t SLEEP = 4;
};

static uint8_t state = states::IDLE;

// Arduino pin for nnboard LED. For debugging. Active high.
const int kLedPin = 13;

// Arduino potentiometer analog input pin.
static const int kPotPin = A0;

// Arduino input pin for the forward (push) button. Active low.
static const int kForwardButtonPin = 7;

// Arduino input pin for the backward (pull) button. Active low.
static const int kBackwardButtonPin = 6;

// After this idle time, the power to the motor is
// disconnected. 
static const uint32_t kSleepTimeMillis =20*1000;

// Speeds in steps/sec.
static const int kBackwardSpeed = 500;

// Time in millis since entering the current state.
static uint32_t current_state_start_time_millis = 0;

// TODO: why do we need this to compile. The function is just below.
//static void setState(uint8_t newState);

// A common function to change state.
static void setState(uint8_t newState) {
  if (newState != state) {
    Serial.print(state);
    Serial.print(" --> ");
    Serial.println(newState);
    state = newState;
    current_state_start_time_millis = millis();
  }
}

static inline uint32_t millisInCurrentState() {
  return (millis() - current_state_start_time_millis);
}

// Using this as a poor man debouncing in states that we entered
// due to a button action.
static inline boolean debouncingDelay() {
   return millisInCurrentState() >= 25;
}

// Consts of a single segment of the pot value mapping function.
struct MapSegment {
  const int inMin;
  const int inMax;
  const int outMin;
  const int outMax;
};

// Consts for all the segments of the pot value mapping function.
static const MapSegment kMapSegments[] = {
  {  0,   128,  1,    2},
  {128,   256,  2,    4},
  {256,   384,  4,   10},
  {384,   512, 10,   22},
  {512,  640,  22,   48},
  {640,  768,  48,  105},
  {768,  896, 105,  229},
  {896, 1023, 229,  500},
};

// NUmber of segments in kMapSegments.
const int kNumMapSegments = sizeof(kMapSegments) / sizeof(kMapSegments[0]);

// Map pot value to speed. We use an aproximation of a logarithmic
// function using the linear segments in kMapSegments.
int mapPotValue(int potValue) {
  potValue = constrain(potValue, 0, 1023);
  for (int i = 0; i < kNumMapSegments; i++) {
    const MapSegment& s = kMapSegments[i];
    if (potValue <= s.inMax) {
      // TODO: precompute dIn and dOut.
      return (int) (((long)potValue - s.inMin) * (s.outMax - s.outMin) / (s.inMax - s.inMin)) + s.outMin;
    }
  }
  return kMapSegments[kNumMapSegments - 1].outMax;
}

// These two are updated each time readPostAsSpeed() is called.
static unsigned long timeLastPotReadMillis = 0;
static int lastPotValueAsSpeed = 0;

// Read pot value and return it mapped to speed.
static int readPotAsSpeed() {
  timeLastPotReadMillis = millis();
  const int potValue = analogRead(kPotPin);
  lastPotValueAsSpeed = mapPotValue(potValue);
  Serial.print("S:");
  Serial.println(lastPotValueAsSpeed);
  return lastPotValueAsSpeed;
}

inline long millisSinceLastPotRead() {
  return millis() - timeLastPotReadMillis;
}

inline bool isForwardButtonPressed() {
  // TODO: debounce.
  //
  // Active low.
  return !digitalRead(kForwardButtonPin);
}

inline bool isBackwardButtonPressed() {
  // TODO: debounce.
  //
  // Active low.
  return !digitalRead(kBackwardButtonPin);
}

// Arduino initialization function.
void setup() {
  Serial.begin(115200);
  
  pinMode(kLedPin, OUTPUT);

  pinMode(kForwardButtonPin, INPUT_PULLUP);
  pinMode(kBackwardButtonPin, INPUT_PULLUP);

  motor::setup();
  motor::setSpeed(0, true);
}

// Arduino main loop function.
void loop() {  
  // Update the motor outputs as needed.
  motor::loop();

  // TODO: have a more interesting LED pattern. Currently it's on iff
  // in a state that turns the motor.
  digitalWrite(kLedPin, motor::isNonZeroSpeed());

  // Here when last motion operation is completed.
  switch (state) {
    case states::IDLE:
      if (millisInCurrentState() >= kSleepTimeMillis) {
        motor::sleep();
        setState(states::SLEEP);
        return;
      }
      // Handle buttons unly after minimal debouncing delay.
      if (!debouncingDelay()) {
        return;
      }
      //
      // Handle Forward button press.
      if (isForwardButtonPressed()) {
        motor::setSpeed(readPotAsSpeed(), true);
        setState(states::FORWARD);
        return;
      }
      // Handle Backward button press.
      if (isBackwardButtonPressed()) {
        motor::setSpeed(kBackwardSpeed, false);
        setState(states::BACKWARD);
        return;
      }
      break;

    case states::FORWARD:
      // Handle Forward button release.
      if (!isForwardButtonPressed() && debouncingDelay()) {
        motor::setSpeed(0, true);
        setState(states::IDLE);
        return;
      }
      // Handle pot changes.
      if (millisSinceLastPotRead() >= 250) {
        motor::setSpeed(readPotAsSpeed(), true);
      }
      break;

    case states::BACKWARD:
      // Handle Backward button release.
      if (!isBackwardButtonPressed() && debouncingDelay()) {
        motor::setSpeed(0, true);
        setState(states::IDLE);
        return;
      }
      break;

    case states::SLEEP:
      if (isForwardButtonPressed() || isBackwardButtonPressed()) {
        motor::setSpeed(0, false);
        setState(states::IDLE);
        return;  
      }
      break;

    default:
      // Should never happend.
      Serial.println("Unknown state");
      // This also prints the unknown state.
      setState(states::IDLE);
  }
}
