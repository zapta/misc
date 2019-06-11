
#include "monitor.h"
#include "passive_timer.h"
#include "rgb_led.h"

#define HWSERIAL Serial1

// Onboard Arduino led. Used for diagnostics.
#define LED (13)
//static PassiveTimer led_timer;

// Max luminicity in the range [0-255].
#define L 255
#define L2 (L / 2)
#define L3 (L / 3)

static const rgb_led::Color NO_TRAFFIC_COLOR = rgb_led::make_color(0,   0,   L);  // Blue (blinks)
static const rgb_led::Color ERRORS_COLOR     = rgb_led::make_color(L2,  L2,  0);  // yellow (blinks)
static const rgb_led::Color ACTIVE_COLOR     = rgb_led::make_color(L,   0,   0);  // Red
static const rgb_led::Color COOLING_COLOR    = rgb_led::make_color(L,   L3,  0);  // orange
static const rgb_led::Color AT_REST_COLOR    = rgb_led::make_color(0,   L,   0);  // Green

// We use the arduino on board LED to indicate reception of status
// report messages. Each message triggers a short blip.
static PassiveTimer traffic_timer;

enum TrafficState {
  // Had a recent status report message
  OK,
  // Didn't have a status report for a medium period. Assuming paneldue busy.
  BUSY,
  // Didn't have a status report for a long time.
  ERROR
};

static TrafficState traffic_state = OK;

void setup() {
  rgb_led::setup();

  pinMode(LED, OUTPUT);
  digitalWrite(LED, LOW);

  Serial.begin(115200);
  HWSERIAL.begin(57600);

  Serial.print("setup completed");

  // Start with a single led ping
  digitalWrite(LED, HIGH);
  //traffic_timer.restart();

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

  // Process pending serial chars.
  while (HWSERIAL.available() > 0) {
    const char c = (char)HWSERIAL.read();
    monitor::ProcessNextChar(c);
  }

  // Report events, if any. For diagnostics. We ignore traffic event
  // to reduce spam.
  const int events = monitor::ConsumePendingEvents();
  if (events & ~monitor::HAD_TRAFFIC) {
    Serial.print("Events: ");
    Serial.println(events);
  }

  // Turn off diagnostic led ping after a short timeout.
  if (digitalRead(LED) && traffic_state == OK && traffic_timer.timeMillis() > 10) {
    digitalWrite(LED, LOW);
  }
  
  // Track serial PanelDue communiction traffic state. We use the reports
  // events as a proxy for the traffic.
  // We use a long timeout since the duet does not report while executing
  // commands such as homming or messing.
  const bool got_report =   (events & (monitor::REPORTED_ACTIVE | monitor::REPORTED_COOLING | monitor::REPORTED_AT_REST));
  if (got_report) {
    digitalWrite(LED, HIGH);
    traffic_state = OK;
    traffic_timer.restart();
  } else if (traffic_state == OK && traffic_timer.timeMillis() > 2500) {
    // Missed a few report. Assume PanelDue started a blocking operation.
    traffic_state = BUSY;
    traffic_timer.restart();
  } else if (traffic_state == BUSY && traffic_timer.timeMillis() > 600 * 1000) {
    // Missed reports for a long time. Maybe a connection or other communication error.
    traffic_state = ERROR;
    // No need to restart timer. We don't care about it in this state.
  }

  // Update RGB led status if needed. Note that no-change settings are
  // efficently ignored by the RGB module.rgb_module.
  if (traffic_state == BUSY) {
    rgb_led::set(ACTIVE_COLOR, 0);  // same as Active below.
  } else if (traffic_state != OK) {
    rgb_led::set(NO_TRAFFIC_COLOR, 1000);  // error
  } else if (events & monitor::HAD_ERRORS) {
    rgb_led::set(ERRORS_COLOR, 300);
  } else if (events & monitor::REPORTED_ACTIVE) {
    rgb_led::set(ACTIVE_COLOR, 0);
  } else if  (events & monitor::REPORTED_COOLING) {
    rgb_led::set(COOLING_COLOR, 0);
  } else if  (events & monitor::REPORTED_AT_REST) {
    rgb_led::set(AT_REST_COLOR, 0);
  }
}
