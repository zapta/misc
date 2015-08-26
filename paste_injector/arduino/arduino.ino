#include <AccelStepper.h>

const int kHalfStep = 8;

// Arduino output pins to the 28BYJ-48 motor driver.
const int  kMotorPin1 = 6;     // IN1 on the ULN2003 driver 1
const int  kMotorPin2 = 7;     // IN2 on the ULN2003 driver 1
const int  kMotorPin3 = 8;     // IN3 on the ULN2003 driver 1
const int  kMotorPin4 = 9;     // IN4 on the ULN2003 driver 1

const int kButton1 = 10;
const int kButton2 = 11;

const int kMinDistance = 250;

// Initialize with pin sequence IN1-IN3-IN2-IN4 for using the AccelStepper with 

AccelStepper stepper(kHalfStep, kMotorPin1, kMotorPin3, kMotorPin2, kMotorPin4);

const int kSpeed = 1000; //speed of the stepper (steps per second)

// True -> apply pressue. 
boolean direction = true; //keep track if we are turning or going straight next

void setup() {

   // initialize the pushbutton pin as an input:
  pinMode(kButton1, INPUT_PULLUP);  
  pinMode(kButton2, INPUT_PULLUP);  
  
  delay(1000); //sime time to put the robot down after swithing it on

  stepper.setMaxSpeed(4000.0);
  
  stepper.move(1);  // I found this necessary
  stepper.setSpeed(kSpeed);
}
void loop() {

  if (!stepper.distanceToGo()) {
    int target = 0;
    if (!digitalRead(kButton1)) {
      target = kMinDistance;
    } else if (!digitalRead(kButton2)) {
      target = -kMinDistance;
    }
    //onst int target = direction ? 20000 : -30000;
    if (target) {
      stepper.move(target);
      stepper.setSpeed(kSpeed);
    }
    direction = !direction;
  }

  stepper.runSpeedToPosition();
//  stepper2.runSpeedToPosition();
}
