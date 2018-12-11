// https://github.com/SpenceKonde/ATTinyCore/blob/master/avr/extras/ATtiny_x8.md

// LED pins
#define RED_LED_NEG 9  
#define YELLOW_LED_NEG 10  

// Motor control outputs
#define X1 2  
#define X2 1   
#define Y1 3
#define Y2 15

// Input signals
#define DOOR_OPENED 24 
#define PROXIMITY 25
#define PARKING 26  

// the setup function runs once when you press reset or power the board
void setup() {  
  // Initialize motor drivers outputs as in state.
  // Outupts start by default in LOW state.
  pinMode(X1, OUTPUT);
  pinMode(X2, OUTPUT);
  pinMode(Y1, OUTPUT);
  pinMode(Y2, OUTPUT);

  // Initialize LED outputs in off state.
  digitalWrite(RED_LED_NEG, HIGH);  
  digitalWrite(YELLOW_LED_NEG, HIGH);  
  pinMode(RED_LED_NEG, OUTPUT);
  pinMode(YELLOW_LED_NEG, OUTPUT);

  // Initialize inputs
  pinMode(DOOR_OPENED, INPUT);
  pinMode(PROXIMITY, INPUT);
  pinMode(PARKING, INPUT);
}

boolean state = LOW;

void loop() {
  for(;;) {
    if (digitalRead(PROXIMITY)) {
      digitalWrite(RED_LED_NEG, HIGH);   
      digitalWrite(YELLOW_LED_NEG, LOW); 
    } else {
      state = !state;
      digitalWrite(RED_LED_NEG, state);   
      digitalWrite(YELLOW_LED_NEG, HIGH); 
    }
    delay(100);                      
  }                       
}
