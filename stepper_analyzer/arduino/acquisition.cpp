

#include "acquisition.h"

#include <string.h>
#include <stdio.h>
#include <TimerOne.h>

#include "io.h"
#include "filters.h"

namespace acquisition {
// TODO: define a const for the reciprocal to speed up conversion to amps.
//
// 12 bit -> 4096 counts.
// 3.3V full scale.
// 0.2V per AMP (for +/- 5A sensor).
const float COUNTS_PER_AMP = 0.2 * 4096 / 3.3;
// We use this value to do multiplications instead of divisions.
const float AMPS_PER_COUNT = 1 / COUNTS_PER_AMP;
const float MILLIAMPS_PER_COUNT = 1000 / COUNTS_PER_AMP;

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

// Allowed range for adc zero current offset. This range is much 
// wider than needed and actual offsets are expected to be around 1900.
const int MIN_OFFSET =   0;
const int MAX_OFFSET = 4095;  // 12 bits max

// [0.0, 1.0], higher = less filtering.
const float SIGNAL_FILTER_K = 0.3;

// Slow filter, for display purposes.
const float DISPLAY_FILTER_K = 1.0 / 1000;

namespace isr_data {
  // Mofified by the ISR. Disable interrupts to access.
  static State isr_state;
  
  
  // Mofified by the ISR. Disable interrupts to access.
  
  static CalibrationData calibration_data;
  
  static int capture_size;
  static uint32_t capture_divider;
  static uint32_t capture_tick_counter;
  static bool capture_active;
  static CaptureBuffer capture_buffer;
}  // namespace isr_data


extern bool is_capture_ready() {
  bool result;
  __disable_irq();
  {
    result = !isr_data::capture_active;
  }
  __enable_irq();
  return result;
}

extern void start_capture(int divider) {
  io::set_led2();

  if (divider < 1) {
    divider = 1;
  } else if (divider > 1000) {
    divider = 1000;
  }

  __disable_irq();
  {
    isr_data::capture_size = 0;
    isr_data::capture_divider = (uint32_t)divider;
    isr_data::capture_tick_counter = 0;
    isr_data::capture_active = true;
  }
  __enable_irq();
}


void get_capture(CaptureBuffer* buffer) {
  __disable_irq();
  {
    *buffer = isr_data::capture_buffer;
  }
  __enable_irq();  
}


// Return a copy of the acquision state.
void get_state(State* state) {
  __disable_irq();
  {
    *state = isr_data::isr_state;
  }
  __enable_irq();
}

// Reset the history portion of the state.
void reset_history() {
  __disable_irq();
  {
    isr_data::isr_state.non_energized_count = 0;
    isr_data::isr_state.full_steps = 0;
    isr_data::isr_state.quadrature_errors = 0;
    memset(isr_data::isr_state.buckets, 0, sizeof(isr_data::isr_state.buckets));
  }
  __enable_irq();
}

// Convert adc value to milliamps.
int adc_value_to_milliamps(int adc_value) {
  return (int)(adc_value * MILLIAMPS_PER_COUNT);
}

// Convert adc value to milliamps.
float adc_value_to_amps(int adc_value) {
  return ((float)adc_value) * AMPS_PER_COUNT;;
}

void calibrate_zeros(CalibrationData* calibration_data) {
  __disable_irq()
  {
    isr_data::calibration_data.offset1 += isr_data::isr_state.display_v1;
    isr_data::calibration_data.offset2 += isr_data::isr_state.display_v2;

    *calibration_data = isr_data::calibration_data;
  }
  __enable_irq();
}

static char buffer[200];

void dump_state(const State& acq_state) {
  static uint32_t last_isr_count = 0;

  sprintf(buffer, "[%lu][er:%lu|%lu] [%5d, %5d] [en:%d %lu] s:%d/%d  steps:%d",
          acq_state.isr_count - last_isr_count,
          acq_state.sampling_errors, acq_state.quadrature_errors,
          acq_state.display_v1, acq_state.display_v2, acq_state.is_energized, acq_state.non_energized_count,
          acq_state.quadrant, acq_state.last_step_direction,  acq_state.full_steps);
  last_isr_count = acq_state.isr_count;
  Serial.println(buffer);

  for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
    Serial.print(acq_state.buckets[i].total_ticks_in_steps);
    Serial.print(" ");
  }
  Serial.println();

  for (int i = 0; i < acquisition::NUM_BUCKETS; i++) {
    if (!acq_state.buckets[i].total_steps) {
      Serial.print(0);
    } else {
      Serial.print((uint32_t)(acq_state.buckets[i].total_step_peak_currents / acq_state.buckets[i].total_steps));
    }
    Serial.print(" ");
  }
  Serial.println();
}

// Assumed to be in READY state.
 void dump_capture(const CaptureBuffer& buffer) {
  for (int i = 0; i < acquisition::CAPTURE_SIZE; i++) {
    const acquisition::CaptureItem& item =buffer.items[i];
    Serial.print(-15);
    Serial.print(' ');
    Serial.print(item.v1);
    Serial.print(' ');
    Serial.print(item.v2);
    Serial.print(' ');
    Serial.println(15);
  }
}

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
  HistogramBucket& bucket = isr_data::isr_state.buckets[bucket_index];
  bucket.total_ticks_in_steps += ticks;
  bucket.total_step_peak_currents += max_current_in_step;
  bucket.total_steps++;
}

// Update the isr state for a new pair of readings.
// Called from isr
inline void isr_process_adc_results(int adc1_reading, int adc2_reading) {
  isr_data::isr_state.isr_count++;

  // Make it zero current relative.
  const int raw_v1 = adc1_reading - isr_data::calibration_data.offset1;
  const int raw_v2 = adc2_reading - isr_data::calibration_data.offset2;

  // We use these filters to reduce internal and external noise.
  static LowPassFilter signal1_filter(SIGNAL_FILTER_K, 0.0);
  static LowPassFilter signal2_filter(SIGNAL_FILTER_K, 0.0);

  // Slow filter, for display purposes.
  static LowPassFilter display1_filter(DISPLAY_FILTER_K, 0.0);
  static LowPassFilter display2_filter(DISPLAY_FILTER_K, 0.0);

  const int v1 = (int)signal1_filter.update(raw_v1);
  const int v2 = (int)signal2_filter.update(raw_v2);

  // Update isr status with latest readings.
  isr_data::isr_state.display_v1 = (int)display1_filter.update(raw_v1);
  isr_data::isr_state.display_v2 = (int)display2_filter.update(raw_v2);

  // Hangle capturing.
  if (isr_data::capture_active) {
    if (isr_data::capture_size < CAPTURE_SIZE) {
      if ((isr_data::capture_tick_counter++ % isr_data::capture_divider) == 0) {
        CaptureItem& item = isr_data::capture_buffer.items[isr_data::capture_size++];
        item.v1 = (int16_t)v1;
        item.v2 = (int16_t)v2;
      }
    }
    if (isr_data::capture_size >= CAPTURE_SIZE) {
      isr_data::capture_active = false;
      io::reset_led2();
    }
  }

  // Determine if motor is energied. Use hysteresis to reject noise
  const bool old_is_energized = isr_data::isr_state.is_energized;
  const uint32_t total_current = abs(v1) + abs(v2);
  const bool new_is_energized = (total_current > (old_is_energized ? NON_ENERGIZED1 : NON_ENERGIZED2));
  isr_data::isr_state.is_energized = new_is_energized;

  // Handle the case of non energized. No need to go through quandrant decoding.
  if (!new_is_energized) {
    if (old_is_energized) {
      // Becoming non energized.
      isr_data::isr_state.last_step_direction = UNKNOWN_DIRECTION;
      isr_data::isr_state.ticks_in_step = 0;
      isr_data::isr_state.non_energized_count++;
    } else {
      // Staying non energized
    }
    return;
  }

  // Here when energizeed. Decode quadrant.
  //
  // Quadrants are defined such that full steps are in
  // the middle of their respective quadrant.
  const int old_quadrant = isr_data::isr_state.quadrant;
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
  isr_data::isr_state.quadrant = new_quadrant;

  // Track quadrants.
  if (!old_is_energized) {
    // Case 1: motor became energized.
    isr_data::isr_state.last_step_direction = UNKNOWN_DIRECTION;
    isr_data::isr_state.ticks_in_step = 1;
    isr_data::isr_state.max_current_in_step = max_current;
  } else if (new_quadrant == old_quadrant) {
    // Case 2: staying in same quadrant
    isr_data::isr_state.ticks_in_step++;
    if (max_current > isr_data::isr_state.max_current_in_step) {
      isr_data::isr_state.max_current_in_step = max_current;
    }
  } else if (new_quadrant == ((old_quadrant + 1) & 0x03)) {
    // Case 3: Forward step
    isr_data::isr_state.full_steps++;
    isr_add_step_to_histogram(
      old_quadrant, isr_data::isr_state.last_step_direction, FORWARD,
      isr_data::isr_state.ticks_in_step, isr_data::isr_state.max_current_in_step);
    isr_data::isr_state.last_step_direction = FORWARD;
    isr_data::isr_state.ticks_in_step = 1;
    isr_data::isr_state.max_current_in_step = max_current;
  } else if (new_quadrant == ((old_quadrant - 1) & 0x03)) {
    // Case 4: backward step
    isr_data::isr_state.full_steps--;
    isr_add_step_to_histogram(
      old_quadrant, isr_data::isr_state.last_step_direction, BACKWARD,
      isr_data::isr_state.ticks_in_step, isr_data::isr_state.max_current_in_step);
    isr_data::isr_state.last_step_direction = BACKWARD;
    isr_data::isr_state.ticks_in_step = 1;
    isr_data::isr_state.max_current_in_step = max_current;
  } else {
    // Case 5: Invalid quadrant transition.
    isr_data::isr_state.quadrature_errors++;
    isr_data::isr_state.last_step_direction = UNKNOWN_DIRECTION;
    isr_data::isr_state.ticks_in_step = 1;
    isr_data::isr_state.max_current_in_step = max_current;
  }
}

// This ISR routine is invoked at samppling rate. It reads the two ADC
// channels, start the conversion for next cycle and calls isr_process_adc_results()
// to process the values read.
void adcTimingIsr() {
  // For debugging
  io::set_led1();

  // Read ADC1, ADC2 values from previous cycle.
  int result1;
  int result2;
  if ((ADC1_HS & ADC_HS_COCO0) &&  (ADC2_HS & ADC_HS_COCO0)) {
    result1 = ADC1_R0;
    result2 = ADC2_R0;
  } else {
    isr_data::isr_state.sampling_errors++;
    // Arbitrary error values
    result1 = 1000;
    result2 = 0;
  }

  // Start ADC1, ADC2 for next cycle
  ADC2_HC0 = adc2_pin_channel;
  ADC1_HC0 = adc1_pin_channel;

  // Process results from previous cycle.
  isr_process_adc_results(result1, result2);

  // For debugging
  io::reset_led1();
}

//#define FULL32BIT 0xFFFFFFFF

static int clip_offset(int requested_offset) {
  return max(MIN_OFFSET, min(MAX_OFFSET, requested_offset));
}

void setup(CalibrationData& calibration_data) {

  isr_data::calibration_data.offset1 = clip_offset(calibration_data.offset1);
  isr_data::calibration_data.offset2 = clip_offset(calibration_data.offset2);

  // --- ADC
  pinMode(adc1_pin, INPUT);
  pinMode(adc2_pin, INPUT);
  analogReadRes(12);       // reading 12 bits
  analogReadAveraging(1);  // TODO: consider to increase to 4

  // Dummy reads to make sure analog inputs are initialized. (needed?)
  analogRead(adc1_pin);
  analogRead(adc2_pin);

  //--- timer
  //
  // TDOO: why setting PWM for pin TIMER1_B_PIN, the real output, doesn't work?
  pinMode(TIMER1_B_PIN, OUTPUT);        // Timer output - pin 7.
  Timer1.initialize(10);                // 20 us = 50 kHz
  Timer1.pwm(TIMER1_A_PIN, 1024 / 4);   // 25% (abitrary)
  Timer1.attachInterrupt(adcTimingIsr); // ISR
}

}  // namespace acquisition
