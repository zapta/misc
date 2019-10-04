

#include "acquisition.h"

#include <string.h>
#include <stdio.h>
#include <TimerOne.h>
#include "io.h" 

namespace acquisition {

// ADC count for i=0 (1.5v of 3.3V full scale)
const uint16_t VAL1_OFFSET = 1902;
const uint16_t VAL2_OFFSET = 1860;

// 12 bit -> 4096 counts.
// 3.3V full scale.
// 0.2V per AMP (for +/- 5A sensor).
const float COUNTS_PER_AMP = 0.2 * 4096 / 3.3;

// Non energized limit, with hysteresis.
// TODO: define a macro and declare in milliamps units.
const uint32_t NON_ENERGIZED1 = 50;
const uint32_t NON_ENERGIZED2 = 150;

//Hysteresis for quadrant boundaries.
const int QUADRANT_HYSTERESIS_MILLIAMPS = 100;
// TODO: define and use a macro to convert milliamps to adc counts.
const int QUADRANT_HYSTERESIS_COUNTS = (QUADRANT_HYSTERESIS_MILLIAMPS * COUNTS_PER_AMP) / 1000;

static const int adc1_pin = A9;  // = 23
static const int adc2_pin = A3;  // = 17

static const uint8_t adc1_pin_channel = 14;  
static const uint8_t adc2_pin_channel = 11;  


// Updated by the ADC interrupt routing.
static State isr_state;

// Maybe add step's information to the histogram.
// Called from isr when existing a step.
inline void isr_add_step_to_histogram(
    int quadrant, Direction entry_direction, Direction exit_direction, 
    uint32_t ticks, uint32_t max_current_in_step) {
  // Ignoring this step if not entering and exiting this step in same forward or backward direction.
  if (entry_direction != exit_direction || entry_direction == UNKNOWN_DIRECTION) {
    return;
  }
  uint32_t speed = 50000 / ticks;  // speed in steps per second
  if (speed < 50) {
    return;   // ignore very slow steps as they dominate the histogram.
  }
  uint32_t bucket_index = speed / 100;   // Each bucket represents a speed range of 100 steps/sec.
  if (bucket_index >= NUM_BUCKETS) {
    bucket_index =  NUM_BUCKETS - 1;
  }
  HistogramBucket& bucket = isr_state.buckets[bucket_index];
  bucket.total_ticks_in_steps += ticks;
  bucket.total_step_peak_currents += max_current_in_step;
  bucket.total_steps++;
}

// Update the isr state for a new pair of readings.
// Called from isr
inline void isr_process_adc_results(int v1, int v2) {
  // Apply offsets to be zero relative.
  v1 -= VAL1_OFFSET;
  v2 -= VAL2_OFFSET;

  // Update isr status with latest readings.
  isr_state.isr_count++;
  isr_state.adc_val1 = v1;
  isr_state.adc_val2 = v2;

  // Append readings to capture buffer if needed.
  //if (isr_state.capture_size < MAX_CAPTURE_SIZE) {
  //  capture[isr_state.capture_size][0] = v1;
  //  capture[isr_state.capture_size][1] = v2;
  //  isr_state.capture_size++;
  //}

  // Determine if motor is energied. Use hysteresis to reject noise
  const bool old_is_energized = isr_state.is_energized;
  const uint32_t total_current = abs(v1) + abs(v2);
  const bool new_is_energized = (total_current > (old_is_energized ? NON_ENERGIZED1 : NON_ENERGIZED2));
  isr_state.is_energized = new_is_energized;

  // Handle the case of non energized. No need to go through quandrant decoding.
  if (!new_is_energized) {
    if (old_is_energized) {
      // Becoming non energized.
      isr_state.last_step_direction = UNKNOWN_DIRECTION;
      isr_state.ticks_in_step = 0;
      isr_state.non_energized_count++;
    } else {
      // Staying non energized
    }
    return;
  }
    
  // Here when energizeed. Decode quadrant.
  //
  // Quadrants are defined such that full steps are in
  // the middle of their respective quadrant.
  const int old_quadrant = isr_state.quadrant;
  // Introduce hystersis in the comparison of |v1| > |v2| which determines 
  // quadrants boundaries. This is to reject noise and avoid bouncing around
  // quadrant boundaries. The hysterestis is controlled by the previous quadrant.
  const int v1_hysteresis = (old_quadrant & 0x01) 
      ? -QUADRANT_HYSTERESIS_COUNTS / 2  // odd quadrant, dominated by |v1| <= |v2|
      : QUADRANT_HYSTERESIS_COUNTS / 2;  // even quadrant, dominated by |v1| > |v2|
  int new_quadrant; // set below to [0, 3]
  uint32_t max_current;  // max coil current
  //int vtotal;  // set below to |v1| + |v2|
  if (v1 >= 0) {
    if (v2 >= 0) {
      // v1 >= 0, v2 >= 0
      if ((v1 + v1_hysteresis) > v2) {
        new_quadrant = 0;
        max_current = v1;
      } else {
        new_quadrant = 1;
        max_current = v2;
      }
      //vtotal = v1 + v2;
    } else {
      // v1 >= 0, v2 < 0
      if ((v1 + v1_hysteresis) > -v2) {
        new_quadrant = 0;
        max_current = v1;
      } else {
        new_quadrant = 3;
        max_current = -v2;
      }
      //vtotal = v1 + -v2;
    }
  } else {
    if (v2 >= 0) {
      // v1 < 0, v2 >= 0
      if ((-v1 + v1_hysteresis) > v2) {
         new_quadrant = 2;
         max_current = -v1;
      } else {
         new_quadrant = 1;
         max_current = v2;
      }
      //vtotal = -v1 + v2;
    } else {
      // v1 < 0, v2 < 0
      if ((-v1 + v1_hysteresis) > -v2) {
        new_quadrant = 2;
        max_current = -v1;
      } else {
        new_quadrant = 3;
        max_current = -v2;
      }
      //vtotal = -v1 + -v2;
    }
  }
  isr_state.quadrant = new_quadrant;

  // Track quadrants.
  if (!old_is_energized) {
    // Case 1: motor became energized.
    isr_state.last_step_direction = UNKNOWN_DIRECTION;
    isr_state.ticks_in_step = 1;
    isr_state.max_current_in_step = max_current;
  } else if (new_quadrant == old_quadrant) {
    // Case 2: staying in same quadrant
    isr_state.ticks_in_step++;
    if (max_current > isr_state.max_current_in_step) {
      isr_state.max_current_in_step = max_current;
    }
  } else if (new_quadrant == ((old_quadrant + 1) & 0x03)) {
    // Case 3: Forward step
    isr_state.full_steps++;
    isr_add_step_to_histogram(
        old_quadrant, isr_state.last_step_direction, FORWARD, 
        isr_state.ticks_in_step, isr_state.max_current_in_step);
    isr_state.last_step_direction = FORWARD;
    isr_state.ticks_in_step = 1;
    isr_state.max_current_in_step = max_current;
  } else if (new_quadrant == ((old_quadrant - 1) & 0x03)) {
    // Case 4: backward step
    isr_state.full_steps--;
    isr_add_step_to_histogram(
        old_quadrant, isr_state.last_step_direction, BACKWARD, 
        isr_state.ticks_in_step, isr_state.max_current_in_step);
    isr_state.last_step_direction = BACKWARD;
    isr_state.ticks_in_step = 1;
    isr_state.max_current_in_step = max_current;
  } else {
    // Case 5: Invalid quadrant transition.
    isr_state.quadrature_errors++;
    isr_state.last_step_direction = UNKNOWN_DIRECTION;
    isr_state.ticks_in_step = 1;
    isr_state.max_current_in_step = max_current;
  }
}

// This ISR routine is invoked at samppling rate. It reads the two ADC
// channels, start the conversion for next cycle and calls isr_process_adc_results() 
// to process the values read.
void adcTimingIsr() {
  // For debugging
  io::set_led1();
  //digitalWriteFast(LED3, true);

  // Read ADC1, ADC2 values from previous cycle.
  int result1;
  if (ADC1_HS & ADC_HS_COCO0) {
    result1 = ADC1_R0;
  } else {
    result1 = 1000;
  }

  int result2;
  if (ADC2_HS & ADC_HS_COCO0) {
      result2 = ADC2_R0;
  } else {
    // Should never get here.
    result2 = 0;
  }

  // Start ADC1, ADC2 for next cycle
  ADC2_HC0 = adc2_pin_channel;
  ADC1_HC0 = adc1_pin_channel;

  // Process results from previous cycle.
  isr_process_adc_results(result1, result2);
   
  // For debugging  
  io::reset_led1();
  //digitalWriteFast(LED3, false);
}

void setup() {
  
  // --- ADC
  pinMode(adc1_pin, INPUT);
  pinMode(adc2_pin, INPUT);
  analogReadRes(12);       // reading 12 bits
  analogReadAveraging(1);  // TODO: consider to increase to 4

  //--- timer
  //
  // TDOO: why setting PWM for pin TIMER1_B_PIN, the real output, doesn't work?
  pinMode(TIMER1_B_PIN, OUTPUT);        // Timer output - pin 7.
  Timer1.initialize(20);                // 20 us = 50 kHz
  //Timer1.initialize(200);                // 20 us = 50 kHz
  Timer1.pwm(TIMER1_A_PIN, 1024/4);     // 25% (abitrary)
  Timer1.attachInterrupt(adcTimingIsr); // ISR
}

// Return a copy of the acquision state.
void get_state(State* state) {
  __disable_irq();
  {
    *state = isr_state;
  }
  __enable_irq();
}

// Reset the history portion of the state.
void reset_history() {
  __disable_irq();
    {
      isr_state.non_energized_count = 0;
      isr_state.full_steps = 0;
      isr_state.quadrature_errors = 0;
      //isr_state.capture_size = 0;
      memset(isr_state.buckets, 0, sizeof(isr_state.buckets)); 
    }
    __enable_irq();
}

// Convert adc value to milliamps.
int adc_value_to_milliamps(int adc_value) {
  return (1000 * adc_value) / COUNTS_PER_AMP;
}

// Convert adc value to milliamps.
float adc_value_to_amps(int adc_value) {
  return ((float)adc_value) / COUNTS_PER_AMP;
}


}  // namespace acquisition
