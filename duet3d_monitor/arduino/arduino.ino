
#include "monitor.h"
#include "passive_timer.h"
#include "rgb_led.h"

#define HWSERIAL Serial1
#define LED (13)

static const rgb_led::Color INITIAL_COLOR = rgb_led::make_color(0, 0, 0);

static const rgb_led::Color NO_TRAFFIC_COLOR = rgb_led::make_color(0, 0, 50);
static const rgb_led::Color ERRORS_COLOR = rgb_led::make_color(25, 25, 0);
static const rgb_led::Color ACTIVE_COLOR = rgb_led::make_color(50, 0, 0);
static const rgb_led::Color INACTIVE_COLOR = rgb_led::make_color(0, 50, 0);

// Starts when led is set on.
static PassiveTimer led_timer;

static PassiveTimer traffic_timer;
static bool traffic_timeout = false;

void setup() {
  rgb_led::setup();

  pinMode(LED, OUTPUT);
  digitalWrite(LED, LOW);

  Serial.begin(115200);
  HWSERIAL.begin(57600);

  Serial.print("setup completed");

  // Start with a single led ping
  digitalWrite(LED, HIGH);
  led_timer.restart();

  rgb_led::set(INITIAL_COLOR, false);

}

void loop() {
  rgb_led::loop();


  // Turn off led after timeout.
  if (digitalRead(LED) && led_timer.timeMillis() > 100) {
    digitalWrite(LED, LOW);
  }

  // Process pending serial chars.
  while (HWSERIAL.available() > 0) {
    const char c = (char)HWSERIAL.read();
    monitor::ProcessNextChar(c);
  }

  // Report events, if any
  const int events = monitor::ConsumePendingEvents();
  if (events & ~monitor::HAD_TRAFFIC) {
    Serial.print("Events: ");
    Serial.println(events);
  }

  // Ping LED if a report was found.
  if (events & (monitor::REPORTED_ACTIVE | monitor::REPORTED_INACTIVE)) {
    digitalWrite(LED, HIGH);
    led_timer.restart();
  }

  // Track traffic timeout
  // We use a long timeout since the duet does not report while executing 
  // commands such as homming or messing.
  if (events & monitor::HAD_TRAFFIC) {
    traffic_timeout = false;
    traffic_timer.restart();
  } else if (!traffic_timeout && traffic_timer.timeMillis() > 10*60*1000) {
    traffic_timeout = true;
  }

  if (traffic_timeout) {
    rgb_led::set(NO_TRAFFIC_COLOR, true);
  } else if (events & monitor::HAD_ERRORS) {
    rgb_led::set(ERRORS_COLOR, true);
  } else if (events & monitor::REPORTED_INACTIVE) {
    rgb_led::set(INACTIVE_COLOR, false);
  } else if  (events & monitor::REPORTED_ACTIVE) {
    rgb_led::set(ACTIVE_COLOR, false);
  }
}
