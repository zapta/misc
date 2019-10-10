
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

static uint64_t histogram_buffer[acquisition::NUM_BUCKETS] = {};

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

void setup() {
  tft.initR(INITR_BLACKTAB);
  tft.fillScreen(ST7735_BLACK);
  tft.setTextWrap(false);
}

static char buffer[200] = {};

void draw_info_screen(acquisition::State& acq_state, bool full_redraw) {
  if (full_redraw) {
    tft.fillScreen(ST7735_BLACK);
  }

  tft.setTextColor(ST7735_GREEN, ST7735_BLACK);
  tft.setCursor(123, 152);
  tft.print("1");

  tft.setTextColor(ST7735_WHITE, ST7735_BLACK);

  tft.setCursor(0, 10);
  const int x0 = 25;
  const int dy = 20;
  int y = 20;

  tft.setCursor(x0, y);
  sprintf(buffer, "A      %6.2f",  acquisition::adc_value_to_amps(acq_state.display_v1));
  tft.print(buffer);
  y += dy;

  tft.setCursor(x0, y);
  sprintf(buffer, "B      %6.2f",  acquisition::adc_value_to_amps(acq_state.display_v2));
  tft.print(buffer);
  y += dy;


  tft.setCursor(x0, y);
  sprintf(buffer, "ERRORS %6lu",  acq_state.quadrature_errors);
  tft.print(buffer);
  y += dy;

  tft.setCursor(x0, y);
  sprintf(buffer, "POWER     %s",  acq_state.is_energized ? " ON" : "OFF");
  tft.print(buffer);
  y += dy;

  tft.setCursor(x0, y);
  sprintf(buffer, "IDLES  %6lu",  acq_state.non_energized_count);
  tft.print(buffer);
  y += dy;

  tft.setTextColor(ST7735_YELLOW, ST7735_BLACK);
  y += dy;
  tft.setCursor(x0, y);
  sprintf(buffer, "STEPS  %6d",  acq_state.full_steps);
  tft.print(buffer);
}

void draw_time_histogram_screen(acquisition::State& acq_state, bool full_redraw) {
  if (full_redraw) {
    tft.fillScreen(ST7735_BLACK);
  }

  tft.setTextColor(ST7735_GREEN, ST7735_BLACK);
  tft.setCursor(123, 152);
  tft.print("2");

  for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
    histogram_buffer[i] = acq_state.buckets[i].total_ticks_in_steps;
  }
  draw_histogram_buffer();
}

void draw_amps_histogram_screen(acquisition::State& acq_state, bool full_draw) {
  if (full_draw) {
    tft.fillScreen(ST7735_BLACK);
  }
 
  tft.setTextColor(ST7735_GREEN, ST7735_BLACK);
  tft.setCursor(123, 152);
  tft.print("3");

  // copy values to buffer
  for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
    const acquisition::HistogramBucket& bucket = acq_state.buckets[i];
    if (bucket.total_steps == 0) {
      histogram_buffer[i] = 0;
    } else {
      // current in millis
      histogram_buffer[i] = acquisition::adc_value_to_milliamps(bucket.total_step_peak_currents / bucket.total_steps);
    }
  }
  draw_histogram_buffer();
}

void draw_signals_screen(acquisition::CaptureBuffer& signals, bool signals_changed) {
 if (!signals_changed) {
    return;
  }
  
  tft.fillScreen(ST7735_BLACK);

  tft.setTextColor(ST7735_GREEN, ST7735_BLACK);
  tft.setCursor(123, 152);
  tft.print("4");

  const int Y0 = 110;
  const int K = 10;
  tft.drawFastHLine(0, Y0, tft.width(), ST7735_WHITE);

  int prev_y1 = Y0 - signals.items[0].v1 / K;
  int prev_y2 = Y0 - signals.items[0].v2 / K;
  for (int i = 1; i < 128; i++) {
    int y1 = Y0 - signals.items[i].v1 / K;
    int y2 = Y0 - signals.items[i].v2 / K;
    tft.drawLine(i-1, prev_y1, i, y1, ST7735_GREEN);
    tft.drawLine(i-1, prev_y2, i, y2, ST7735_RED);
    prev_y1 = y1;
    prev_y2 = y2;
  }

  
  // TODO: draw signals 
}


}  // namespace display
