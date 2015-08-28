// Controller the solder paste injector.

// TODO: turn off the power to the motor after a long idle period.
// TODO: perform a longer backlash after a long idle period.

#include <AccelStepper.h>


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

// Distnaces in steps. Positive extrudes, negative pulls back.
const int kForwardSteps  =    10;
const int kBacklashSteps =  -300;
const int kBackwardSteps =  -300;

// Speeds in steps/sec.
//const int kForwardSpeed  =   25;
const int kBacklashSpeed = 1000;
const int kBackwardSpeed = 1000;

// NOTE: the pins are not listed by their numeric order.
AccelStepper stepper(kHalfStep, 
    kMotorPin1, 
    kMotorPin3, 
    kMotorPin2, 
    kMotorPin4);

// TODO: why do we need this to compile. The function is just below.
static void setState(State newState);

static void setState(State newState) {
  if (newState != state) {
    Serial.print(state);
    Serial.print(" --> ");
    Serial.println(newState);
    state = newState;
  }
}

struct MapSegment {
  const int inMin;
  const int inMax;
  const int outMin;
  const int outMax;
};

static const MapSegment kMapSegments[] = {
  {  0,   128,  1,   2}, 
  {128,   256,  2,   4}, 
  {256,   384,  4,  10}, 
  {384,   512, 10,  22}, 
  {512,  640,  22,  48}, 
  {640,  768,  48, 105}, 
  {768,  896, 105, 229}, 
  {896, 1023, 229, 500}, 
};

const int kNumMapSegments = sizeof(kMapSegments) / sizeof(kMapSegments[0]);

int mapPotValue(int potValue) {
  //potValue = constrain(potValue, 0, 500);
  //Serial.println(potValue);
  for (int i=0; i<kNumMapSegments; i++) {
    const MapSegment& s = kMapSegments[i];
    //Serial.println(i);
    if (potValue <= s.inMax) {
      //Serial.println("y");
      // TODO: precompute dIn and dOut.
      return (int) (((long)potValue - s.inMin) * (s.outMax - s.outMin) / (s.inMax - s.inMin)) + s.outMin;
    }
  }
  //Serial.println("x");
  return kMapSegments[kNumMapSegments-1].outMax;
}

static unsigned long timeLastPotReadMillis = 0;

static int readPotAsSpeed() {
   timeLastPotReadMillis = millis();
   const int potValue = analogRead(kPotPin);
   return mapPotValue(potValue);
}

inline long millisSinceLastPotRead() {
  return millis() - timeLastPotReadMillis;
}

inline bool isForwardButtonPressed() {
  // Active low.
  return !digitalRead(kForwardButtonPin);  
}

inline bool isBackwardButtonPressed() {
  // Active low.
  return !digitalRead(kBackwardButtonPin);  
}

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

void loop() {
  // Here when last motion operation is completed.
  switch (state) {

    case IDLE:    
      // Forward button.
      if (isForwardButtonPressed()) { 
        stepper.setSpeed(readPotAsSpeed());
        setState(FORWARD);
        return;
      }   
      // Backward button. 
      if (isBackwardButtonPressed()) { 
        stepper.setSpeed(kBackwardSpeed);
        setState(BACKWARD);
        return;
      }
      break;

    case FORWARD:
      stepper.runSpeed();
      // If forward button got released, stop the forward motion and do the 
      // backlash sequece to avoid oozing.
      if (!isForwardButtonPressed()) { 
        stepper.move(kBacklashSteps);
        stepper.setSpeed(kBacklashSpeed);
        setState(BACKLASH);
        return;
      }
      // Update the speed from the pot once in a while.
      if (millisSinceLastPotRead() >= 100) {
        stepper.setSpeed(readPotAsSpeed());  
      }
      break;
      
    case BACKLASH:
      stepper.runSpeedToPosition();
      if (!stepper.distanceToGo()) {
        setState(IDLE); 
        return; 
      }
      break;

    case BACKWARD:
      stepper.runSpeed();
      // If backeard button got released then stop the backward motion.
      if (!isBackwardButtonPressed()) { 
        stepper.move(0);
        setState(IDLE);
        return;
      }
      break;

    default:
      // Should never happend.
      Serial.println("Unknown state");
      setState(IDLE);
  }
}
