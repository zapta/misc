

#ifndef ACQUISITION_H
#define ACQUISITION_H

#include <arduino.h>
#include <string.h>
#include <stdio.h>

namespace acquisition {

// NOTE: if changing this struct, change also in eeprom.cpp.
struct Settings {
  int offset1;
  int offset2;
  bool reverse_direction;
};

const int CAPTURE_SIZE = 420;

struct CaptureItem {
  int16_t v1;
  int16_t v2;
};

struct CaptureBuffer {
  CaptureItem items[CAPTURE_SIZE];
};

enum Direction {
  UNKNOWN_DIRECTION,
  FORWARD,
  BACKWARD
};

// 100KHz sampling.
const int USECS_PER_TICK = 10;
const int TICKS_PER_SEC = 1000000 / USECS_PER_TICK;

const int MAX_MILLIAMPS = 2500;
const int NUM_BUCKETS = 20;
// Each histogram bucket represents a speed range of 100 
// steps per sec, starting from zero. Overflow counts are
// aggregated in the last bucket.
const int BUCKET_SPAN = 100;

// A single histogram bucket
struct HistogramBucket {
  uint32_t total_ticks_in_steps;       // total adc samples in steps in this bucket;
  uint64_t total_step_peak_currents;   // total max step current in ADC counts
  uint32_t total_steps;                // total steps
};

struct State {
  public:
    State() :
      isr_count(0), display_v1(0), display_v2(0),
      is_energized(false), non_energized_count(0), quadrant(0),
      full_steps(0), quadrature_errors(0), sampling_errors(0),
      last_step_direction(UNKNOWN_DIRECTION), max_current_in_step(0), ticks_in_step(0) {
      memset(buckets, 0, sizeof(buckets));
    }

    // Number of isr invocactions so far. Overlofw is normal.
    uint32_t isr_count;
    // Slow filtered values of v1, v2, in adc count units.
    int  display_v1;
    int  display_v2;
    // True if coils are energized.
    bool is_energized;
    // Number of times coils were deenergized.
    uint32_t non_energized_count;
    // The current quadrant, one of [0, 1, 2, 3]. Each quadrant
    // represents half of a full step.
    int quadrant;
    // Total (forward - backward) full steps (quadrant transitions).
    int full_steps;
    // Total invalid quadrant transitions. Normally 0.
    uint32_t quadrature_errors;
    // Number of ticks DAC results were not ready
    uint32_t sampling_errors;
    // for tracking step speed
    Direction last_step_direction;
    // AdC counts, single coil.
    uint32_t max_current_in_step; // max current in current step, in ADC count units. Dominate coild.
    uint32_t ticks_in_step; // ticks in current step.
    // Histogram, each bucket represents a range of steps/sec speeds.
    HistogramBucket buckets[NUM_BUCKETS];
};

extern void dump_state(const State& acq_state);
extern void dump_capture(const CaptureBuffer& capture_buffer );


extern bool is_capture_ready();

extern void get_capture(CaptureBuffer* buffer);

extern void start_capture(int divider);

extern void stop_capture();

// Called once during program setup.
extern void setup(Settings& settings);

// Return a copy of the acquision state.
extern void get_state(State* state);

// Reset the history portion of the state.
extern void reset_history();

// Convert adc value to milliamps.
extern int adc_value_to_milliamps(int adc_value);

// Convert adc value to amps.
extern float adc_value_to_amps(int adc_value);

extern void calibrate_zeros(Settings* settings);

extern void set_direction(bool reverse_direction, Settings* settings);

extern bool is_reverse_direction();

}  // namespace acquisition

#endif
