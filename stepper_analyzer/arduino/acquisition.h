

#ifndef ACQUISITION_H
#define ACQUISITION_H

#include <arduino.h>
#include <string.h>
#include <stdio.h>

namespace acquisition {

enum Direction {
  UNKNOWN_DIRECTION,
  FORWARD,
  BACKWARD
};

const int NUM_BUCKETS = 20;

// A single histogram bucket
struct HistogramBucket {
  uint32_t total_ticks_in_steps;       // total adc samples in steps in this bucket;
  uint64_t total_step_peak_currents;   // total max step current in ADC counts
  uint32_t total_steps;                // total steps
};

struct State {
  public:
    State() :
      isr_count(0), adc_val1(0), adc_val2(0),
      is_energized(false), non_energized_count(0), quadrant(0), 
      full_steps(0), quadrature_errors(0),  
      last_step_direction(UNKNOWN_DIRECTION), max_current_in_step(0), ticks_in_step(0) {
      memset(buckets, 0, sizeof(buckets)); 
    }
    
    // Number of isr invocactions so far. Overlofw is normal.
    uint32_t isr_count;
    // Signed adc current readings. For a 200mv/A current sensor, units
    // are (0.2V * 4095)/3.3V = 248 counts/A.
    int  adc_val1;
    int  adc_val2;
    bool is_energized;
    uint32_t non_energized_count;
    // The current quadrant, one of [0, 1, 2, 3]. Each quadrant
    // represents half of a full step.
    int quadrant;
    // Total (forward - backward) full steps (quadrant transitions).
    int full_steps;
    // Total invalid quadrant transitions. Normally 0.
    uint32_t quadrature_errors;
    //int capture_size;
    // for tracking step speed
    Direction last_step_direction;
    // AdC counts, single coil.
    uint32_t max_current_in_step; // max current in current step, in ADC count units. Dominate coild.
    uint32_t ticks_in_step; // ticks in current step.
    // Histogram, each bucket represents a range of steps/sec speeds.
    HistogramBucket buckets[NUM_BUCKETS];
};

// Called once during program setup.
extern void setup();

// Return a copy of the acquision state.
extern void get_state(State* state);

// Reset the history portion of the state.
extern void reset_history();

// Convert adc value to milliamps.
extern int adc_value_to_milliamps(int adc_value);

// Convert adc value to amps.
extern float adc_value_to_amps(int adc_value);

}  // namespace acquisition

#endif
