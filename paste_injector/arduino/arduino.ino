// Controller the solder paste injector.

// TODO: turn off the power to the motor after a long idle period.
// TODO: perform a longer backlash after a long inactivity period.

#include <AccelStepper.h>

// Finite state machine states.
enum State {
  // Not moving.
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
};

static State state = IDLE;

// Onboard LED. For debugging. Active high.
const int kLedPin = 13;

// Potentiometer analog input pin.
const int kPotPin = A0;

// The mottor has 8 half steps for a full revolution, before the down gearing.
const int kHalfStep = 8;

// Arduino output pins to the 28BYJ-48 motor driver.
const int  kMotorPin1 = 6;     
const int  kMotorPin2 = 7;    
const int  kMotorPin3 = 8;     
const int  kMotorPin4 = 9;     

const int kForwardButtonPin = 10;
const int kBackwardButtonPin = 11;

const int kBacklashSteps =  300;


// Speeds in steps/sec.
const int kBacklashSpeed = 1000;
const int kBackwardSpeed = 1000;   

// If forward speed is higher than this speed 
// then do a backlash before stopping.
const int kMinForwardSpeedForBacklash = 100;

// NOTE: the pins are not listed by their numeric order.
AccelStepper stepper(kHalfStep, 
    kMotorPin1, 
    kMotorPin3, 
    kMotorPin2, 
    kMotorPin4);

// TODO: why do we need this to compile. The function is just below.
static void setState(State newState);

// A common function to change state.
static void setState(State newState) {
  if (newState != state) {
    Serial.print(state);
    Serial.print(" --> ");
    Serial.println(newState);
    state = newState;
  }
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
  {896, 1023, 229, 1000}, 
};

// NUmber of segments in kMapSegments.
const int kNumMapSegments = sizeof(kMapSegments) / sizeof(kMapSegments[0]);

// Map pot value to speed. We use an aproximation of a logarithmic
// function using the linear segments in kMapSegments.
int mapPotValue(int potValue) {
  potValue = constrain(potValue, 0, 1023);
  for (int i=0; i<kNumMapSegments; i++) {
    const MapSegment& s = kMapSegments[i];
    if (potValue <= s.inMax) {
      // TODO: precompute dIn and dOut.
      return (int) (((long)potValue - s.inMin) * (s.outMax - s.outMin) / (s.inMax - s.inMin)) + s.outMin;
    }
  }
  return kMapSegments[kNumMapSegments-1].outMax;
}

// These two are updated each time readPostAsSpeed() is called.
static unsigned long timeLastPotReadMillis = 0;
static int lastPogValueAsSpeed = 0;

// Read pot value and return it mapped to speed. 
static int readPotAsSpeed() {
   timeLastPotReadMillis = millis();
   const int potValue = analogRead(kPotPin);
   lastPogValueAsSpeed = mapPotValue(potValue);
   return lastPogValueAsSpeed;
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
  pinMode(kLedPin, OUTPUT);
  
   // initialize the pushbutton pin as an input:
  pinMode(kForwardButtonPin, INPUT_PULLUP);  
  pinMode(kBackwardButtonPin, INPUT_PULLUP);  

  Serial.begin(115200);

  stepper.setMaxSpeed(4000.0);

  // This is required to get the motor library going.
  stepper.move(1);
  stepper.setSpeed(500);
  while (stepper.distanceToGo()) {
    stepper.runSpeedToPosition();
  }
}

// Arduino main loop function.
void loop() {
  // Here when last motion operation is completed.
  switch (state) {

    case IDLE:    
      // TODO: do we need to keep updating the motor driver evne when stopped?
      //
      // Handle Forward button press.
      if (isForwardButtonPressed()) { 
        stepper.setSpeed(readPotAsSpeed());
        setState(FORWARD);
        return;
      }   
      // Handle Backward button press. 
      if (isBackwardButtonPressed()) { 
        stepper.setSpeed(-kBackwardSpeed);
        setState(BACKWARD);
        return;
      }
      break;

    case FORWARD:
      // Update motor drive. This state uses continious fixed speed mode.
      stepper.runSpeed();
      // Handle Forward button release.
      if (!isForwardButtonPressed()) { 
        // If moved fast do anti oozing.
        if (lastPogValueAsSpeed >= kMinForwardSpeedForBacklash) {
          stepper.move(-kBacklashSteps);
          stepper.setSpeed(kBacklashSpeed);
          setState(BACKLASH);
        } else {
          // Moved slow. Just stop.
          stepper.move(0);
          setState(IDLE);
        }
        return;
        
      }
      // Handle pot changes.
      if (millisSinceLastPotRead() >= 100) {
        stepper.setSpeed(readPotAsSpeed());  
      }
      break;
      
    case BACKLASH:
      // Update motor driver. This state uses fixe distance move mode.
      stepper.runSpeedToPosition();
      // Handle movement done.
      if (!stepper.distanceToGo()) {
        setState(IDLE); 
        return; 
      }
      break;

    case BACKWARD:
      // Update motor driver. This state uses continious fixed speed mode.
      stepper.runSpeed();
      // Handle Backward button release.
      if (!isBackwardButtonPressed()) { 
        stepper.move(0);
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
