// Controller the solder paste injector.

#include <AccelStepper.h>

const int kHalfStep = 8;

// Arduino output pins to the 28BYJ-48 motor driver.
const int  kMotorPin1 = 6;     
const int  kMotorPin2 = 7;    
const int  kMotorPin3 = 8;     
const int  kMotorPin4 = 9;     

const int kForwardButtonPin = 10;
const int kBackwardButtonPin = 11;

const int kForwardSteps = 400;
const int kBacklashSteps = 200;
const int kBackwardSteps = 300;

const int kForwardSpeed = 500;
const int kBacklashSpeed = 1000;
const int kBackwardSpeed = 1000;

//const int kMinDistance = 250;

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

// Steps: positive -> extrude.
void setMotion(int steps, int speed) {
  stepper.move(steps);
  stepper.setSpeed(speed);
}

void setup() {
   // initialize the pushbutton pin as an input:
  pinMode(kForwardButtonPin, INPUT_PULLUP);  
  pinMode(kBackwardButtonPin, INPUT_PULLUP);  

  //delay(1000); //sime time to put the robot down after swithing it on

  stepper.setMaxSpeed(1000.0);

  setMotion(1, 500);
}

void loop() {
  stepper.runSpeedToPosition();

  if (stepper.distanceToGo()) {
    return;
  }

  // Here when last motion completed.
  switch (state) {
    case IDLE:
    case BACKLASH:
    case BACKWARD:
      // Forward button.
      if (isForwardButtonPressed()) { 
        setMotion(kForwardSteps, kForwardSpeed); 
        state = FORWARD;
      // Backward button.
      } else if (isBackwardButtonPressed()) { 
        setMotion(-kBackwardSteps, kBackwardSpeed);
        state = BACKWARD;
      // Default, be in IDLE state.
      } else {
        state = IDLE;
      }
      break;

    case FORWARD:
      // Forward button: continue forward.
      if (isForwardButtonPressed()) { 
        setMotion(kForwardSteps, kForwardSpeed); 
        state = FORWARD;
        return;
      }     
      // Forward done: do backlash to reduce oozing.
      setMotion(-kBacklashSteps, kBacklashSpeed);
      state = BACKLASH;
      break;

    default:
      state = IDLE;
  }
}
