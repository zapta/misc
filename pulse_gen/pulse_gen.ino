/*
  Button

  Turns on and off a light emitting diode(LED) connected to digital
  pin 13, when pressing a pushbutton attached to pin 2.


  The circuit:
   LED attached from pin 13 to ground
   pushbutton attached to pin 2 from +5V
   10K resistor attached to pin 2 from ground

   Note: on most Arduinos there is already an LED on the board
  attached to pin 13.


  created 2005
  by DojoDave <http://www.0j0.org>
  modified 30 Aug 2011
  by Tom Igoe

  This example code is in the public domain.

  http://www.arduino.cc/en/Tutorial/Button
*/


const int button = 2;     // the number of the pushbutton pin
const int led =  13;      // the number of the LED pin
const int out = 11;

bool stable_state = true;

int change_start = millis();

void pulse() {
  delay(5000);
  Serial.println("Pules");
  digitalWrite(led, 1);
  digitalWrite(out, 1);
  delay(100);
  digitalWrite(out, 0);
  digitalWrite(led, 0);
}

void setup() {
  Serial.begin(57600);

  digitalWrite(led, 0);
  pinMode(led, OUTPUT);


  pinMode(button, INPUT);

  digitalWrite(out, 0);
  pinMode(out, OUTPUT);
}

void loop() {
  bool state_changed = false;

  // Handle button.
  bool new_state = digitalRead(button);
  if (new_state == stable_state) {
    change_start = millis();
  } else {
    if ((millis() - change_start) > 100) {
      stable_state = new_state;
      change_start = millis();
      state_changed = true;
      //Serial.print("Change - > ");
      //Serial.println(stable_state);
    }
  }

  if (state_changed && stable_state == true) {
    pulse();
  }
}
