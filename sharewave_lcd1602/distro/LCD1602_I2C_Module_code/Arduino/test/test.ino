#include <Wire.h>
#include "Waveshare_LCD1602.h"


Waveshare_LCD1602 lcd(16,2);  //16 characters and 2 lines of show
int r,g,b,t=0;
void setup() {
    // initialize
    lcd.init();
    
    lcd.setCursor(0,0);
    lcd.send_string("Waveshare");
    lcd.setCursor(0,1);
    lcd.send_string("Hello,World!!!");
}

void loop() {
    delay(150);
}
