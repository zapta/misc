
#include "display.h"

#include <string.h>
#include <stdio.h>
#include <ST7735_t3.h>

namespace display {

// Display is 1.8", portrait, 128 x 160.
#define TFT_SCLK 13  // SCLK (also LED_BUILTIN so don't use it) Can be 14 on T3.2
#define TFT_MOSI 11  // MOSI can also use pin 7
#define TFT_CS   10  // CS & DC can use pins 2, 6, 9, 10, 15, 20, 21, 22, 23
#define TFT_DC    9  //   but certain pairs must NOT be used: 2+10, 6+9, 20+23, 21+22
#define TFT_RST   8  // RST can use any pin

static ST7735_t3 tft(TFT_CS, TFT_DC, TFT_MOSI, TFT_SCLK, TFT_RST);

enum ScreenId {
  INFO_SCREEN,
  TIME_HISTOGRAM_SCREEN,
  AMPS_HISTOGRAM_SCREEN
};

static ScreenId screen_id = INFO_SCREEN;

static uint64_t histogram_buffer[acquisition::NUM_BUCKETS] = {};

// Indicates that screen changed and needs full redraw.
static bool needs_full_redraw = true;

// Draw an histogram from the data histogram_buffer.
static void draw_histogram_buffer() {
    // Determine full scale value
    uint64_t full_scale = 1;
    for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
      if (histogram_buffer[i] > full_scale) {
        full_scale = histogram_buffer[i];
      }
    }

    // Draw 
    for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
      const uint64_t value = histogram_buffer[i];
      // TODO: change the bar length calculation to round fraction of pixels up.
      int bar_length = (100 * value) / full_scale;
      if (value > 0 && bar_length < 1) {
        bar_length = 1;
      }

      // Buckets are drawen buttom up on the screen.
      const int x0 =  10;
      const int y = 3 + (acquisition::NUM_BUCKETS - i) * 7;
      // First x, y is 0,0 (upper left corner).
      if (bar_length > 0) {
        tft.fillRect(x0, y , bar_length, 6, ST7735_YELLOW);
        tft.fillRect(x0 + bar_length, y , 100 - bar_length, 6, ST7735_BLACK);
      } else {
        // Bar of length 1 in a neutral color
        tft.fillRect(x0, y , 1, 6, ST7735_BLUE);  // TODO: make gray
        tft.fillRect(x0 + 1, y , 100 - 1, 6, ST7735_BLACK);  
      }
    }  
}

//void update_display(const acquisition::State& state) {
//}

void next_screen() {
  // Increment the screen id, wrapping around if at end.
  // Screen will be painted in next update.
  if (screen_id == AMPS_HISTOGRAM_SCREEN) {
    screen_id = INFO_SCREEN;
  } else {
    screen_id=(ScreenId)((int)screen_id+1);
  }
  needs_full_redraw = true;
}

void setup() {
  tft.initR(INITR_BLACKTAB);
  tft.fillScreen(ST7735_BLACK);
  tft.setTextWrap(false);
}

static char buffer[200] = {};

static void update_info_screen(const acquisition::State& state, bool full_redraw) {
  if (full_redraw) {
    tft.fillScreen(ST7735_BLACK);
  }

  tft.setCursor(0, 10);
  const int x0 = 25;
  const int dy = 20;
  int y = 20;

  tft.setCursor(x0, y);
  sprintf(buffer, "A      %6.2f",  acquisition::adc_value_to_amps(state.adc_val1));
  tft.print(buffer);
  y += dy;

  tft.setCursor(x0, y);
  sprintf(buffer, "B      %6.2f",  acquisition::adc_value_to_amps(state.adc_val2));
  tft.print(buffer);
  y += dy;


  tft.setCursor(x0, y);
  sprintf(buffer, "ERRORS %6lu",  state.quadrature_errors);
  tft.print(buffer);
  y += dy;

  tft.setCursor(x0, y);
  sprintf(buffer, "POWER     %s",  state.is_energized? " ON" : "OFF");
  tft.print(buffer);
  y += dy;

  tft.setCursor(x0, y);
  sprintf(buffer, "IDLES  %6lu",  state.non_energized_count);
  tft.print(buffer);
  y += dy;

  tft.setTextColor(ST7735_YELLOW, ST7735_BLACK);
  y += dy;
  tft.setCursor(x0, y);
  sprintf(buffer, "STEPS  %6d",  state.full_steps);
  tft.print(buffer);
}

static void update_time_histogram_screen(const acquisition::State& state, bool full_redraw) {
  if (full_redraw) {
    tft.fillScreen(ST7735_BLACK);
  }
  tft.setCursor(80, 120);
  tft.print("Screen 2");
  for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
    histogram_buffer[i] = state.buckets[i].total_ticks_in_steps;
  }
  draw_histogram_buffer();
}

static void update_amps_histogram_screen(const acquisition::State& state, bool full_redraw) {
  if (full_redraw) {
    tft.fillScreen(ST7735_BLACK);
  }
  tft.setCursor(80, 120);
  tft.print("Screen 3");
  // copy values to buffer
  for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
    const acquisition::HistogramBucket& bucket = state.buckets[i];
    if (bucket.total_steps == 0) {
      histogram_buffer[i] = 0;
    } else {
      // current in millis
      histogram_buffer[i] = acquisition::adc_value_to_milliamps(bucket.total_step_peak_currents / bucket.total_steps);
    }
  }
  draw_histogram_buffer();
}

void update_screen(const acquisition::State& state) {
  switch (screen_id) {
    case INFO_SCREEN:
      update_info_screen(state, needs_full_redraw);
      break;
    case TIME_HISTOGRAM_SCREEN:
      update_time_histogram_screen(state, needs_full_redraw);
      break;
    case AMPS_HISTOGRAM_SCREEN:
      update_amps_histogram_screen(state, needs_full_redraw);
      break;
    default:
      tft.fillScreen(ST7735_RED);
      break;
  }
  needs_full_redraw = false;
}

}  // namespace display
