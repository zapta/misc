
#include "monitor.h"

#define HWSERIAL Serial1
#define LED 13


void setup() {
  pinMode(LED, OUTPUT);
  digitalWrite(LED, LOW);

  Serial.begin(115200);
  HWSERIAL.begin(57600);

  Serial.print("setup completed");
}

void loop() {

  while (HWSERIAL.available() > 0) {
    const char c = (char)HWSERIAL.read();
    monitor::ProcessNextChar(c);
  }

  const int events = monitor::ConsumePendingEvents();
  if (events & ~monitor::HAD_TRAFFIC) {
    Serial.print("Events: ");
    Serial.println(events);
    digitalWrite(LED, events & monitor::REPORTED_ACTIVE);
  }
}
