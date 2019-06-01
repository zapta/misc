
#include "monitor.h"
#include "passive_timer.h"
#include "rgb_led.h"

#define HWSERIAL Serial1

// Onboard Arduino led. Used for diagnostics.
#define LED (13)
static PassiveTimer led_timer;

// Max luminicity in the range [0-255].
#define L 250

static const rgb_led::Color NO_TRAFFIC_COLOR = rgb_led::make_color(0,   0,   L);  // Blue
static const rgb_led::Color ERRORS_COLOR     = rgb_led::make_color(L/2, 0,   0);  // Red
static const rgb_led::Color ACTIVE_COLOR     = rgb_led::make_color(L,   L,   L);  // White
static const rgb_led::Color INACTIVE_COLOR   = rgb_led::make_color(0,   L,   0);  // Green


// We use the arduino on board LED to indicate reception of status 
// report messages. Each message triggers a short blip.
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

  // A quick RGB test pattern
  delay(300);
  rgb_led::set(rgb_led::make_color(L, 0, 0), 0);
  delay(300);
  rgb_led::set(rgb_led::make_color(0, L, 0), 0);
  delay(300);
  rgb_led::set(rgb_led::make_color(0, 0, L), 0);
  delay(300);
  rgb_led::set(rgb_led::make_color(0, 0, 0), 0);
}

void loop() {
  rgb_led::loop();

  // Turn off diagnostic led ping after timeout.
  if (digitalRead(LED) && led_timer.timeMillis() > 10) {
    digitalWrite(LED, LOW);
  }

  // Process pending serial chars.
  while (HWSERIAL.available() > 0) {
    const char c = (char)HWSERIAL.read();
    monitor::ProcessNextChar(c);
  }

  // Report events, if any. For diagnostics.
  const int events = monitor::ConsumePendingEvents();
  if (events & ~monitor::HAD_TRAFFIC) {
    Serial.print("Events: ");
    Serial.println(events);
  }

  // If a status message wass detected, ping onboard LED. For diagnostics
  if (events & (monitor::REPORTED_ACTIVE | monitor::REPORTED_INACTIVE)) {
    digitalWrite(LED, HIGH);
    led_timer.restart();
  }

  // Track serial PanelDue communiction traffic timeout
  // We use a long timeout since the duet does not report while executing
  // commands such as homming or messing.
  if (events & monitor::HAD_TRAFFIC) {
    traffic_timeout = false;
    traffic_timer.restart();
  } else if (!traffic_timeout && traffic_timer.timeMillis() > 10 * 60 * 1000) {
    traffic_timeout = true;
  }

  // Update RGB led status if needed. Note that no-change settings are
  // efficently ignored by the RGB module.rgb_module.
  if (traffic_timeout) {
    rgb_led::set(NO_TRAFFIC_COLOR, 1000);
  } else if (events & monitor::HAD_ERRORS) {
    rgb_led::set(ERRORS_COLOR, 300);
  } else if (events & monitor::REPORTED_INACTIVE) {
    rgb_led::set(INACTIVE_COLOR, 0);
  } else if  (events & monitor::REPORTED_ACTIVE) {
    rgb_led::set(ACTIVE_COLOR, 0);
  }
}
