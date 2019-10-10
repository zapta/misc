
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

extern void draw_info_screen(acquisition::State& acq_state, bool full_redraw);
extern void draw_time_histogram_screen(acquisition::State& acq_state, bool full_redraw);
extern void draw_amps_histogram_screen(acquisition::State& acq_state, bool full_redraw);
extern void draw_signals_screen(acquisition::CaptureBuffer& signals, bool signals_change);

}  // namespace display

#endif
