// Controller the solder paste injector.

// TODO: turn off the power to the motor after a long idle period.
// TODO: perform a longer backlash after a long inactivity period.

#include "motor.h"

// Finite state machine states.
enum State {
  // Not moving, motor on.
  IDLE,
  // Moving forward as long as the forward button is pressed.
  // Speed is controlled by the potentiometer.
  FORWARD,
  // Moving a fixed distance at a fast speed backward after releasing
  // the Forward button.
  BACKLASH,
  // Moving backward at a fast speed as long as the Backward button
  // is pressed.
  BACKWARD,
  // Same as IDLE but motor coils are not energized.
  SLEEP,
};

static State state = IDLE;

// Onboard LED. For debugging. Active high.
const int kLedPin = 13;

// Potentiometer analog input pin.
static const int kPotPin = A0;

static const int kForwardButtonPin = 10;
static const int kBackwardButtonPin = 11;

static const uint16_t kBacklashTimeMillis = 1000;

static const uint32_t kSleepTimeMillis = 60*1000;

// Speeds in steps/sec.
static const int kBacklashSpeed = 500;
static const int kBackwardSpeed = 500;

// If forward speed is higher than this speed
// then do a backlash before stopping.
static const int kMinForwardSpeedForBacklash = 100;

static uint32_t current_state_start_time_millis = 0;

// TODO: why do we need this to compile. The function is just below.
static void setState(State newState);

// A common function to change state.
static void setState(State newState) {
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

  motor::setup();
  motor::setSpeed(0, true);
}

// Arduino main loop function.
void loop() {
  // Update the motor outputs as needed.
  motor::loop();

  // Here when last motion operation is completed.
  switch (state) {
    case IDLE:
      if (millisInCurrentState() >= kSleepTimeMillis) {
        motor::sleep();
        setState(SLEEP);
        return;
      }
      //
      // Handle Forward button press.
      if (isForwardButtonPressed()) {
        motor::setSpeed(readPotAsSpeed(), true);
        setState(FORWARD);
        return;
      }
      // Handle Backward button press.
      if (isBackwardButtonPressed()) {
        motor::setSpeed(kBackwardSpeed, false);
        setState(BACKWARD);
        return;
      }
      break;

    case FORWARD:
      // Handle Forward button release.
      if (!isForwardButtonPressed()) {
        // If moved fast do anti oozing.
        if (lastPotValueAsSpeed >= kMinForwardSpeedForBacklash) {
          motor::setSpeed(kBacklashSpeed, false);
          setState(BACKLASH);
        } else {
          // Moved slow. Just stop.
          motor::setSpeed(0, true);
          setState(IDLE);
        }
        return;

      }
      // Handle pot changes.
      if (millisSinceLastPotRead() >= 100) {
        motor::setSpeed(readPotAsSpeed(), true);
      }
      break;

    case BACKLASH:
      // Handle movement done.
      if (millisInCurrentState() >= kBacklashTimeMillis) {
        motor::setSpeed(0, true);
        setState(IDLE);
        return;
      }
      break;

    case BACKWARD:
      // Handle Backward button release.
      if (!isBackwardButtonPressed()) {
        motor::setSpeed(0, true);
        setState(IDLE);
        return;
      }
      break;

    case SLEEP:
      if (isForwardButtonPressed() || isBackwardButtonPressed()) {
        motor::setSpeed(0, false);
        setState(IDLE);
        return;  
      }
      break;

    default:
      // Should never happend.
      Serial.println("Unknown state");
      // This also prints the unknown state.
      setState(IDLE);
  }
}
