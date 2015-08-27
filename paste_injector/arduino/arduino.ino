// Controller the solder paste injector.

// TODO: turn off the power to the motor after a long idle period.
// TODO: perform a longer backlash after a long idle period.
// TODO: try a continious mode (slow push).
// TODO: add a way to set speed, etc (poitentiometers?)

#include <AccelStepper.h>

const int kHalfStep = 8;

// Arduino output pins to the 28BYJ-48 motor driver.
const int  kMotorPin1 = 6;     
const int  kMotorPin2 = 7;    
const int  kMotorPin3 = 8;     
const int  kMotorPin4 = 9;     

const int kForwardButtonPin = 10;
const int kBackwardButtonPin = 11;

// Distnaces in steps. Positive extrudes, negative pulls back.
const int kForwardSteps  =  400;
const int kBacklashSteps = -200;
const int kBackwardSteps = -300;

// Speeds in steps/sec.
const int kForwardSpeed  =  500;
const int kBacklashSpeed = 1000;
const int kBackwardSpeed = 1000;

// NOTE: the pins are not listed by their numeric order.
AccelStepper stepper(kHalfStep, 
    kMotorPin1, 
    kMotorPin3, 
    kMotorPin2, 
    kMotorPin4);

enum State {
  IDLE,
  FORWARD,
  BACKLASH,
  BACKWARD,
};

State state = IDLE;

inline bool isForwardButtonPressed() {
  // Active low.
  !digitalRead(kForwardButtonPin);  
}

inline bool isBackwardButtonPressed() {
  // Active low.
  !digitalRead(kBackwardButtonPin);  
}

// Steps: positive -> extrude, negative pulls back.
void startMotion(int steps, int speed) {
  stepper.move(steps);
  stepper.setSpeed(speed);
}

inline bool isMotionInProgress() {
  return stepper.distanceToGo();
}

void setup() {
   // initialize the pushbutton pin as an input:
  pinMode(kForwardButtonPin, INPUT_PULLUP);  
  pinMode(kBackwardButtonPin, INPUT_PULLUP);  

  //delay(1000); //sime time to put the robot down after swithing it on

  stepper.setMaxSpeed(1000.0);

  // TODO: is this really required?
  startMotion(1, 500);
}

void loop() {
  // This updates the stepper library. Should be call in short
  // intervales.
  stepper.runSpeedToPosition();

  if (isMotionInProgress()) {
    return;
  }

  // Here when last motion operation is completed.
  switch (state) {
    case IDLE:
    case BACKLASH:
    case BACKWARD:
      // Forward button.
      if (isForwardButtonPressed()) { 
        startMotion(kForwardSteps, kForwardSpeed); 
        state = FORWARD;
      // Backward button.
      } else if (isBackwardButtonPressed()) { 
        startMotion(kBackwardSteps, kBackwardSpeed);
        state = BACKWARD;
      // Default, be in IDLE state.
      } else {
        state = IDLE;
      }
      break;

    case FORWARD:
      // Forward button: continue forward.
      if (isForwardButtonPressed()) { 
        startMotion(kForwardSteps, kForwardSpeed); 
        state = FORWARD;
        return;
      }     
      // Forward done: do backlash to reduce oozing.
      startMotion(kBacklashSteps, kBacklashSpeed);
      state = BACKLASH;
      break;

    default:
      // Should never happend.
      state = IDLE;
  }
}
