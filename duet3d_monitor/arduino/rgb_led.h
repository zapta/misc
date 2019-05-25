// Duet state monitor. Parses the sniffed PanelDue serial communication
// and extracts the Duet state.

#ifndef RGB_LED_H
#define RGB_LED_H

#include <stdint.h>

namespace rgb_led {

typedef uint32_t Color;

extern void setup();
extern void loop();
extern Color make_color(uint8_t r, uint8_t g, uint8_t b);
extern void set(Color, bool blink);

}  // namespace rgb_led

#endif
