
#ifndef DISPLAY_H
#define DISPLAY_H

#include <arduino.h>
#include <string.h>
#include <stdio.h>
#include <ST7735_t3.h>

#include "acquisition.h"

namespace display {

// Called once from main setup().
extern void setup();

// Called at fixed intervals.
extern void update_screen(const acquisition::State& state);

extern void next_screen();

}  // namespace display

#endif
