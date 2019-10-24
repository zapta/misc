

#ifndef IO_H
#define IO_H

#include <arduino.h>
#include <Bounce2.h>
#include <elapsedMillis.h>


namespace io {

//--- Push buttons

// Press buttons

class Button {
  public:
    Button(int pin, int interval);
    void update();
    bool is_click();
    bool is_long_press();
  private:
    Bounce _bounce;
    elapsedMillis _elapsed_since_fell;
    bool _is_click;
    bool _is_long_press;
    bool _long_press_armed;
};

extern Button button1;
extern Button button2;

// --- LEDS

const int LED1_PIN = 1;
const int LED2_PIN = 2;
const int LED3_PIN = 3;

// --- LED1

inline void set_led1() {
  digitalWriteFast(LED1_PIN, 1);
}

inline void reset_led1() {
  digitalWriteFast(LED1_PIN, 0);
}

inline void toggle_led1() {
  digitalWriteFast(LED1_PIN, !digitalReadFast(LED1_PIN));
}

// --- LED2

inline void set_led2() {
  digitalWriteFast(LED2_PIN, 1);
}

inline void reset_led2() {
  digitalWriteFast(LED2_PIN, 0);
}

inline void toggle_led2() {
  digitalWriteFast(LED2_PIN, !digitalReadFast(LED2_PIN));
}

// --- LED3

inline void set_led3() {
  digitalWriteFast(LED3_PIN, 1);
}

inline void reset_led3() {
  digitalWriteFast(LED3_PIN, 0);
}

inline void toggle_led3() {
  digitalWriteFast(LED3_PIN, !digitalReadFast(LED3_PIN));
}

// --- DIP switch

// Polarity is inverted since switched short to groun when ON.
// Since switches signals are state based, we don't bother with debouncing.

const int DIP_SWITCH1_PIN = 4;
const int DIP_SWITCH2_PIN = 5;
const int DIP_SWITCH3_PIN = 6;
const int DIP_SWITCH4_PIN = 8;

inline bool dip_switch1() {
  return !digitalReadFast(DIP_SWITCH1_PIN);
}
inline bool dip_switch2() {
  return !digitalReadFast(DIP_SWITCH2_PIN);
}
inline bool dip_switch3() {
  return !digitalReadFast(DIP_SWITCH3_PIN);
}
inline bool dip_switch4() {
  return !digitalReadFast(DIP_SWITCH4_PIN);
}

// ---

// Called once from main setup.
extern void setup();

}  // namespace io

#endif
