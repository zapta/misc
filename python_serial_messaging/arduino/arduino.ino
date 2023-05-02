

void setup() {
  Serial3.begin(115200);
}

void loop() {
  if (Serial3.available()) {        
    Serial3.write(Serial3.read());  
  }
}
