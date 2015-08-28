// Controller the solder paste injector.

// TODO: turn off the power to the motor after a long idle period.
// TODO: perform a longer backlash after a long idle period.
// TODO: try a continious mode (slow push).
// TODO: add a way to set speed, etc (poitentiometers?)

#include <AccelStepper.h>


enum State {
  IDLE = 0,
  FORWARD,
  BACKLASH,
  BACKWARD,
 // STOPPING,
};

static State state = IDLE;

// Arduino Pro Mini onboard LED>
const int kLedPin = 13;
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

int readPotAsSpeed() {
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

// Steps: positive -> extrude, negative pulls back.
//void startFixedMotion(int steps, int speed) {
//  stepper.move(steps);
//  stepper.setSpeed(speed);
//}



//inline bool isFixedMotionInProgress() {
//  stepper.runSpeedToPosition();
//  return stepper.distanceToGo();
//}

void setup() {
  pinMode(kLedPin, OUTPUT);

  //pinMode(kPotentiometerPin);
  
   // initialize the pushbutton pin as an input:
  pinMode(kForwardButtonPin, INPUT_PULLUP);  
  pinMode(kBackwardButtonPin, INPUT_PULLUP);  

  Serial.begin(115200);

  stepper.setMaxSpeed(4000.0);
   stepper.move(1);
  stepper.setSpeed(500);
  //startFixedMotion(1, 500);
  while (stepper.distanceToGo()) {
    stepper.runSpeedToPosition();
  }

  digitalWrite(kLedPin, 1);
  
}

void loop() {
//   const int potValue = analogRead(kPotPin);
//   Serial.println();
//   int m = mapPot(potValue);
//   Serial.print(potValue);
//   Serial.print(" --> ");
//   Serial.println(m);
//   delay(100);
//   return;
   //return;
  
  // This updates the stepper library. Should be call in short
  // intervales.
  //stepper.runSpeedToPosition();

  //digitalWrite(kLedPin, 0);

  //if (isMotionInProgress()) {  
  //  return;
  //}

//digitalWrite(kLedPin, 0);

  // Here when last motion operation is completed.
  switch (state) {

  case IDLE:    
      // Forward button.
      if (isForwardButtonPressed()) { 
        stepper.setSpeed(readPotAsSpeed());
        setState(FORWARD);
        //startMotion(kForwardSteps, readPotAsSpeed()); 
        //state = FORWARD;
      // Backward button.
      } else if (isBackwardButtonPressed()) { 
        stepper.setSpeed(kBackwardSpeed);
        //startFixedMotion(kBackwardSteps, kBackwardSpeed);
        setState(BACKWARD);
      // Default, be in IDLE state.
      }
      break;

      case FORWARD:
      stepper.runSpeed();
      // Forward button: continue forward.
      if (!isForwardButtonPressed()) { 
//        startMotion(kForwardSteps, readPotAsSpeed()); 
//        state = FORWARD;
//        return;
//      }     
      // Forward done: do backlash to reduce oozing.
       // startFixedMotion(kBacklashSteps, kBacklashSpeed);
        stepper.move(kBacklashSteps);
  stepper.setSpeed(kBacklashSpeed);
        setState(BACKLASH);
      } else if (millisSinceLastPotRead() >= 100) {
          stepper.setSpeed(readPotAsSpeed());  
      }
      break;
      
    case  BACKLASH:
    stepper.runSpeedToPosition();
 // return stepper.distanceToGo();
      if (!stepper.distanceToGo()) {
        setState(IDLE);  
      }
      break;

    case BACKWARD:
     stepper.runSpeed();
      // Forward button: continue forward.
      if (!isBackwardButtonPressed()) { 
//        startMotion(kForwardSteps, readPotAsSpeed()); 
//        state = FORWARD;
//        return;
//      }     
        // stepper.moveTo();
        stepper.move(0);
        //stepper.setSpeed(kBackwardSpeed);
        // startFixedMotion(-1, kBackwardSpeed);
      // Forward done: do backlash to reduce oozing.
        //startFixedMotion(kBacklashSteps, kBacklashSpeed);
        setState(IDLE);
      }
      break;

//    case STOPPING:
////      stepper.runSpeedToPosition();
////      if (!stepper.distanceToGo()) {
//        setState(IDLE);
//    //  }
//      break;

    default:
      // Should never happend.
      Serial.println("Unknown state");
      setState(IDLE);
  }
}
