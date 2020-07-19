

#ifndef IO_H
#define IO_H

#include <arduino.h>
//#include <Bounce2.h>
//#include <elapsedMillis.h>


namespace io {


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


// Called once from main setup.
extern void setup();

}  // namespace io

#endif
