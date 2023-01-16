// Implementation of the acquisition module. It uses the ADC/DMA
// interrupts to process the ADC sampling.

// TODO: convert const naming style to kCammelCase.

#include "analyzer.h"

#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "analyzer_private.h"
#include "esp_log.h"
#include "filters.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"
#include "io/io.h"
#include "misc/circular_buffer.h"

namespace analyzer {

static constexpr auto TAG = "analyzer";

static SemaphoreHandle_t data_mutex;
#define ENTER_MUTEX \
  { xSemaphoreTake(data_mutex, portMAX_DELAY); }
#define EXIT_MUTEX \
  { xSemaphoreGive(data_mutex); }

// Private functions for the adc_task.
void enter_mutex() { ENTER_MUTEX }
void exit_mutex() { EXIT_MUTEX }

// xSemaphoreCreateMutex( void );

// Circular buffer of states. Used for state notifications.
// With 20ms per sample, 10 entires provides 200ms buffering.
static CircularBuffer<State, 10> state_circular_buffer;

// We signal this one each time we insert an item to state_circular_buffer.
static SemaphoreHandle_t circular_state_semaphore;

// static K_SEM_DEFINE(circular_state_semaphore, 0, 1);

// Energized/non-energized histeresis limits in ADC
// counts.
//
// TODO: specify here what the limits are as a percentage
// of full current scale.
//
constexpr uint16_t kNonEnergizedThresholdCounts = 50;
constexpr uint16_t kEnergizedThresholdCounts = 150;

// Controls the low pass filter. See filters.h for details.
// Higher value -> more agressive filtering. In the range
// (0, 1024).
constexpr uint16_t kFilterFactor = 700;

// Allowed range for adc zero current offset setting.
// This range is wider than needed and actual offsets
// are expected to be around 1900.
constexpr int kMinOffset = 0;
constexpr int kMaxOffset = 4095;  // 12 bits max

// We capture steps every this number of ADC ticks.
constexpr uint16_t kStepsCaptureDivider =
    acq_consts::TIME_TICKS_PER_SEC / kStepsCaptursPerSec;

enum AdcCaptureState {
  // Blind filling half of the capture buffer. In this state we don't
  // look for a trigger because we want to have at least half a buffer
  // captured before the trigger.
  ADC_CAPTURE_HALF_FILL,
  // Keep filling in a circular way until a trigger event
  // or wait for trigger timeout.
  ADC_CAPTURE_PRE_TRIGGER,
  // Keep filling the buffer until the capture buffer is full.
  // When we complete this state, we clear the buffer and go back
  // to go back to ADC_CAPTURE_HALF_FILL.
  ADC_CAPTURE_POST_TRIGER,
  // Not capturing. ISR is guaranteed not to update or access the
  // capture buffer.

  /// ADC_CAPTURE_IDLE,
};

// This data is accessed from interrupt and thus should
// be access from main() with IRQ disabled.
struct IsrData {
  // The acquisition state visible to users.
  State state;

  // The histogram buffer. Visible to users.
  Histogram histogram;

  // Current settings.
  // Settings settings;

  // Offset settings. See analyzer::Settings.
  int16_t offset1;
  int16_t offset2;

  // Signal capturing members.
  //
  // Capturing state.
  AdcCaptureState adc_capture_state;
  // Time out for waiting for trigger in divided ADC ticks.
  uint32_t adc_capture_pre_trigger_items_left;
  // Factor to divide ADC ticks. Only every n'th sample is captured.
  // Value >= 1.
  uint8_t adc_capture_divider;
  // Up counter for capturing only every n'th samples.
  uint8_t adc_capture_divider_counter;
  // The ADC capture buffer. Updated by ISR when state != CAPTURE_IDLE
  // and accessible by the UI (ready only) when state = CAPTURE_IDLE.
  AdcCaptureBuffer adc_capture_buffer;
  // Each time we complete a sample in the adc_capture_buffer, we snapshot
  // it in this buffer, and start from scratch.
  AdcCaptureBuffer adc_capture_buffer_snapshot;

  // Members for capturing step counter at fixed intervals for notification
  // to the BLE client.
  //
  // The steps capture circula buffer.
  StepsCaptureBuffer steps_capture_buffer;
  // Adc tick counter counter/divider. Use to sample the steps
  // count only every kStepsCaptureDivider adc ticks.
  uint16_t steps_capture_divider_counter;
};

static IsrData isr_data = {};
//  {.adc_capture_state = ADC_CAPTURE_HALF_FILL,
//                            .adc_capture_divider = 1};

void get_last_capture_snapshot(AdcCaptureBuffer* buffer) {
  // adc_dma::disable_irq();
  ENTER_MUTEX {
    // We copy the last completed snapsho.
    *buffer = isr_data.adc_capture_buffer_snapshot;
  }
  EXIT_MUTEX
  // adc_dma::enable_irq();
}



// Should be called from ISR from when interrupts are not enabled.
void isr_reset_adc_capture_buffer() {
  isr_data.adc_capture_buffer.items.clear();
  isr_data.adc_capture_buffer.divider = isr_data.adc_capture_divider;

  isr_data.adc_capture_state = ADC_CAPTURE_HALF_FILL;
  isr_data.adc_capture_pre_trigger_items_left = kAdcCaptureMaxWaitToTrigger;
  isr_data.adc_capture_divider_counter = 0;
}

// Should be called from ISR from when interrupts are not enabled.
void isr_restart_adc_capture_cycle() {
  

  // Snapshot the last sample, if any.
  isr_data.adc_capture_buffer_snapshot = isr_data.adc_capture_buffer;

  // Initialize the new capture buffer.
  isr_data.adc_capture_buffer.seq_number++;
  isr_reset_adc_capture_buffer();

  
}

void sample_histogram(Histogram* histogram) {
  // adc_dma::disable_irq();
  ENTER_MUTEX { *histogram = isr_data.histogram; }
  EXIT_MUTEX
  // adc_dma::enable_irq();
}

static StepsCaptureBuffer steps_capture_sample_buffer;
const StepsCaptureBuffer* sample_steps_capture() {
  steps_capture_sample_buffer.clear();
  // adc_dma::disable_irq();
  ENTER_MUTEX {
    // NOTE: steps_capture_buffer is managed as a circular buffer
    // such it can be empty only when the device starts.
    if (!isr_data.steps_capture_buffer.is_empty()) {
      steps_capture_sample_buffer = isr_data.steps_capture_buffer;
      isr_data.steps_capture_buffer.clear();
    }
  }
  EXIT_MUTEX
  // adc_dma::enable_irq();
  return &steps_capture_sample_buffer;
}

void sample_state(State* state) {
  // adc_dma::disable_irq();
  ENTER_MUTEX { *state = isr_data.state; }
  EXIT_MUTEX
  // adc_dma::enable_irq();
}

// Blocks until next state is available. (50Hz)
bool pop_next_state(State* state) {
  for (;;) {
    const State* popped_state;
    // adc_dma::disable_irq();
    ENTER_MUTEX {
      // Null if buffer is empty.
      popped_state = state_circular_buffer.pop();
      if (popped_state) {
        *state = *popped_state;
      }
    }
    EXIT_MUTEX
    // adc_dma::enable_irq();
    if (popped_state) {
      // TODO: take semaphore if taken.
      return true;
    }

    // Wait for the semaphore
    // k_sem_take(&circular_state_semaphore, K_FOREVER);
    xSemaphoreTake(circular_state_semaphore, portMAX_DELAY);
  }
}

void reset_data() {
  // adc_dma::disable_irq();
  ENTER_MUTEX {
    // NOTE: we don't reset the tick counter,  step counter samples and
    // the captured signals.

    isr_data.state.ticks_with_errors = 0;
    isr_data.state.non_energized_count = 0;
    isr_data.state.full_steps = 0;
    isr_data.state.max_full_steps = 0;
    isr_data.state.max_retraction_steps = 0;
    isr_data.state.quadrature_errors = 0;
    memset(isr_data.histogram.buckets, 0, sizeof(isr_data.histogram.buckets));
  }
  EXIT_MUTEX
  // adc_dma::enable_irq();
}

void calibrate_zeros() {
  // To minimize the effect of the noise on the zero offset
  // we compute an average of the last n states we entered
  // to the notification buffer. We take advantage of the fact
  // that even when we consume a state from the buffer, its
  // value is still available there.
  // adc_dma::disable_irq();
  ENTER_MUTEX {
    const uint16_t n = state_circular_buffer.capacity;
    int32_t total_v1 = 0;
    int32_t total_v2 = 0;
    for (int i = 0; i < n; i++) {
      const State* state = state_circular_buffer.get_internal(i);
      total_v1 += state->v1;
      total_v2 += state->v2;
      // printk("%d %d\n", (int)state->v1, (int)state->v2);
    }
    // isr_data.offset1 += isr_data.state.v1;
    // isr_data.offset2 += isr_data.state.v2;

    // printk("[%d %d]\n", (int)isr_data.state.v1, (int)isr_data.state.v2);

    isr_data.offset1 += (total_v1 / n);
    isr_data.offset2 += (total_v2 / n);
  }
  EXIT_MUTEX
  // adc_dma::enable_irq();
}

void set_is_reversed_direction(bool is_reverse_direction) {
  // adc_dma::disable_irq();
  ENTER_MUTEX { isr_data.state.is_reverse_direction = is_reverse_direction; }
  EXIT_MUTEX
  // adc_dma::enable_irq();
}

bool get_is_reversed_direction() {
  bool result;
  // adc_dma::disable_irq();
  ENTER_MUTEX { result = isr_data.state.is_reverse_direction; }
  EXIT_MUTEX
  // adc_dma::enable_irq();
  return result;
}

void set_signal_capture_divider(uint8_t divider) {
  // Clip to a reaonsable range.
  if (divider < 1) {
    divider = 1;
  } else if (divider > 50) {
    divider = 50;
  }

  // adc_dma::disable_irq();
  ENTER_MUTEX {
    isr_data.adc_capture_divider = divider;
    isr_data.adc_capture_divider_counter = 0;

    // Restart the capture buffer so we don't mix data points
    // from diferent dividers.
    isr_reset_adc_capture_buffer();
  }
  EXIT_MUTEX
  // adc_dma::enable_irq();

  ESP_LOGI(TAG, "Signal capture divider set to %hu", divider);
}

void get_settings(Settings* settings) {
  // adc_dma::disable_irq();
  ENTER_MUTEX {
    settings->offset1 = isr_data.offset1;
    settings->offset2 = isr_data.offset2;
    settings->is_reverse_direction = isr_data.state.is_reverse_direction;
  }
  EXIT_MUTEX
  // adc_dma::enable_irq();
}

void dump_state(const State& state) {
  ESP_LOGI(TAG, 
      "[%6llu][er:%u, %u] [%5d, %5d] [en:%d %u] s:%hhu/%d  steps:%d "
      "max_steps:%d",
      state.tick_count, state.quadrature_errors, state.ticks_with_errors,
      state.v1, state.v2, state.is_energized, state.non_energized_count,
      state.quadrant, state.last_step_direction, state.full_steps,
      state.max_full_steps);
}

// Assumes that ADC capture data is ready.
void dump_adc_capture_buffer(const AdcCaptureBuffer& buffer) {
  printf("\nCapture buffer:\n");
  printf(" seq: %hu, div=%hus\n", buffer.seq_number, buffer.divider);
  for (int i = 0; i < buffer.items.size(); i++) {
    const analyzer::AdcCaptureItem* item = buffer.items.get(i);
    // printf("%03d: %4hd %4hd\n", i, item->v1, item->v2);
    printf("%hd,%hd\n", item->v1, item->v2);
  }
  printf("\n");
}

// Maybe add step's information to the histogram.
// Called from isr on step transition.
static inline void isr_add_step_to_histogram(uint8_t quadrant,
                                             Direction entry_direction,
                                             Direction exit_direction,
                                             uint32_t ticks_in_step,
                                             uint32_t max_current_in_step) {
  // Ignoring this step if not entering and exiting this step in same forward or
  // backward direction.
  if (entry_direction != exit_direction ||
      entry_direction == UNKNOWN_DIRECTION) {
    return;
  }
  uint32_t steps_per_sec = acq_consts::TIME_TICKS_PER_SEC /
                           ticks_in_step;  // speed in steps per second
  if (steps_per_sec < 10) {
    return;  // ignore very slow steps as they dominate the time.
  }
  uint32_t bucket_index = steps_per_sec / acq_consts::kBucketStepsPerSecond;
  if (bucket_index >= acq_consts::kNumHistogramBuckets) {
    bucket_index = acq_consts::kNumHistogramBuckets - 1;
  }
  HistogramBucket& bucket = isr_data.histogram.buckets[bucket_index];
  bucket.total_ticks_in_steps += ticks_in_step;
  bucket.total_step_peak_currents += max_current_in_step;
  bucket.total_steps++;
}

// A helper for the isr function.
static inline void isr_update_full_steps_counter(int increment) {
  State& isr_state = isr_data.state;  // alias

  // Update step counter based on direction setting.
  if (isr_data.state.is_reverse_direction) {
    isr_state.full_steps -= increment;
  } else {
    isr_state.full_steps += increment;
  }

  // Track retraction.
  if (isr_state.full_steps > isr_state.max_full_steps) {
    isr_state.max_full_steps = isr_state.full_steps;
  }
  const int retraction_steps = isr_state.max_full_steps - isr_state.full_steps;
  if (retraction_steps > isr_state.max_retraction_steps) {
    isr_state.max_retraction_steps = retraction_steps;
  }
}

// NOTE: these four filters slow the interrupt handling. Consider
// to eliminate if free CPU time is insufficient.
//
// We use these filters to reduce internal and external noise.
static filters::Adc12BitsLowPassFilter<kFilterFactor> signal1_filter;
static filters::Adc12BitsLowPassFilter<kFilterFactor> signal2_filter;

// This function performs the bulk of the IRQ processing. It accepts
// one pair of ADC1, ADC2 readings, analyzes it, and updates the
// state.
void isr_handle_one_sample(const uint16_t raw_v1, const uint16_t raw_v2) {
  isr_data.state.tick_count++;

  // Every N ADC ticks, capture the steps values.
  if (++isr_data.steps_capture_divider_counter >= kStepsCaptureDivider) {
    isr_data.steps_capture_divider_counter = 0;
    StepsCaptureItem* item = isr_data.steps_capture_buffer.insert();
    item->full_steps = isr_data.state.full_steps;
    item->max_full_steps = isr_data.state.max_full_steps;
  }

  // Slight filtering for signal cleanup.
  const int16_t v1 = (int16_t)signal1_filter.update(raw_v1) - isr_data.offset1;
  const int16_t v2 = (int16_t)signal2_filter.update(raw_v2) - isr_data.offset2;

  // @@@ Temp for testing
  // const int16_t v1 = (int16_t)raw_v1 - isr_data.offset1;
  // const int16_t v2 = (int16_t)raw_v2 - isr_data.offset2;

  isr_data.state.v1 = v1;
  isr_data.state.v2 = v2;

  // Handle adc signal capturing.
  if (++isr_data.adc_capture_divider_counter >= isr_data.adc_capture_divider) {
    isr_data.adc_capture_divider_counter = 0;
    // Insert sample to circular buffer. If the buffer is full it drops
    // the oldest item.
    AdcCaptureItem* adc_capture_item =
        isr_data.adc_capture_buffer.items.insert();
    adc_capture_item->v1 = v1;
    adc_capture_item->v2 = v2;

    switch (isr_data.adc_capture_state) {
      // In this sate we blindly fill half of the buffer.
      case ADC_CAPTURE_HALF_FILL:
        if (isr_data.adc_capture_buffer.items.size() >=
            kAdcCaptureBufferSize / 2) {
          isr_data.adc_capture_state = ADC_CAPTURE_PRE_TRIGGER;
        }
        break;

      // In this state we look for a trigger event or a pre trigger timeout.
      case ADC_CAPTURE_PRE_TRIGGER: {
        // Pre trigger timeout?
        if (isr_data.adc_capture_pre_trigger_items_left == 0) {
          // NOTE: if the buffer is full here we could terminate
          // the capture but we go through the normal motions for simplicity.
          isr_data.adc_capture_state = ADC_CAPTURE_POST_TRIGER;
          // isr_data.adc_capture_buffer.trigger_found = false;
          break;
        }
        isr_data.adc_capture_pre_trigger_items_left--;
        // Is this a trigger event?
        const int16_t old_v1 =
            isr_data.adc_capture_buffer.items.get_reversed(5)->v1;
        // Trigger criteria: crossing up the zero line.
        if (old_v1 < -10 && v1 >= 0) {
          // Keep only the last n/2 points. This way the trigger will
          // always be in the middle of the buffer.
          isr_data.adc_capture_buffer.items.keep_at_most(kAdcCaptureBufferSize /
                                                         2);
          // isr_data.adc_capture_buffer.trigger_found = true;
          isr_data.adc_capture_state = ADC_CAPTURE_POST_TRIGER;
        }
      } break;

      // In this state we blindly fill the rest of the buffer. Note
      // that the current sample was already inserted above.
      case ADC_CAPTURE_POST_TRIGER:
        if (isr_data.adc_capture_buffer.items.is_full()) {
          // We completed a capture cycle. Snapshot the result and start
          // a new cycle.
          isr_restart_adc_capture_cycle();
        }
        break;
    }
  }

  // Determine if motor is energized. Use hysteresis for noise rejection.
  // Release: 200ns. Debug: 600ns.
  const bool old_is_energized = isr_data.state.is_energized;
  const uint16_t total_current = abs(v1) + abs(v2);
  // Using histeresis.
  const uint16_t energized_threshold = old_is_energized
                                           ? kNonEnergizedThresholdCounts
                                           : kEnergizedThresholdCounts;
  const bool new_is_energized = total_current > energized_threshold;
  isr_data.state.is_energized = new_is_energized;

  // Handle the non energized case. No need to go through quadrant decoding.
  // Pass through case: Release: 110ns. Debug: 250ns.
  if (!new_is_energized) {
    if (old_is_energized) {
      // Becoming non energized.
      isr_data.state.last_step_direction = UNKNOWN_DIRECTION;
      isr_data.state.ticks_in_step = 0;
      isr_data.state.non_energized_count++;
    } else {
      // Staying non energized
    }
    return;
  }

  // Here when energized. Decode quadrant.
  // We now go through a decision tree to collect the new quadrant, sector
  // and max coil current. Optimized for speed. See quadrants_plot.png
  // for the individual cases.
  uint8_t new_quadrant;  // set below to [0, 3]
  uint32_t max_current;  // max coil current
  if (v2 >= 0) {
    if (v1 >= 0) {
      // Quadrant 0: v1 > 0, V2 > 0.
      new_quadrant = 0;
      if (v1 > v2) {
        // Sector 0: v1 > 0, V2 > 0.  |v1| > |v2|
        max_current = v1;
      } else {
        // Sector 1: v1 > 0, V2 > 0.  |v1| < |v2|
        max_current = v2;
      }
    } else {
      // Quadrant 1: v1 < 0, V2 > 0
      new_quadrant = 1;
      if (-v1 < v2) {
        // Sector 2: v1 < 0, V2 > 0.  |v1| < |v2|
        max_current = v2;
      } else {
        // Sector 3: v1 < 0, V2 > 0.  |v1| > |v2|
        max_current = -v1;
      }
    }
  } else {
    if (v1 < 0) {
      // Quadrant 2:  v1 < 0, V2 < 0
      new_quadrant = 2;
      if (-v1 > -v2) {
        // Sector 4: v1 < 0, V2 < 0.  |v1| > |v2|
        max_current = -v1;
      } else {
        // Sector 5: v1 < 0, V2 < 0.  |v1| < |v2|
        max_current = -v2;
      }
    } else {
      // Quadrant 3 v1 > 0, V2 < 0.
      new_quadrant = 3;
      if (v1 < -v2) {
        // Sector 6: v1 > 1, V2 < 0.  |v1| < |v2|
        max_current = -v2;
      } else {
        // Sector 7: v1 > 0, V2 < 0.  |v1| > |v2|
        max_current = v1;
      }
    }
  }

  const uint8_t old_quadrant = isr_data.state.quadrant;  // old quadrant [0, 3]
  isr_data.state.quadrant = new_quadrant;

  // Track quadrant transitions and update steps.
  if (!old_is_energized) {
    // Case 1: motor just became energized. Direction is still not known.
    isr_data.state.last_step_direction = UNKNOWN_DIRECTION;
    isr_data.state.ticks_in_step = 1;
    isr_data.state.max_current_in_step = max_current;
  } else if (new_quadrant == old_quadrant) {
    // Case 2: staying in same quadrant
    isr_data.state.ticks_in_step++;
    if (max_current > isr_data.state.max_current_in_step) {
      isr_data.state.max_current_in_step = max_current;
    }
  } else if (new_quadrant == ((old_quadrant + 1) & 0x03)) {
    // Case 3: Moved to next quadrant.
    isr_update_full_steps_counter(+1);
    isr_add_step_to_histogram(old_quadrant, isr_data.state.last_step_direction,
                              FORWARD, isr_data.state.ticks_in_step,
                              isr_data.state.max_current_in_step);
    isr_data.state.last_step_direction = FORWARD;
    isr_data.state.ticks_in_step = 1;
    isr_data.state.max_current_in_step = max_current;
  } else if (new_quadrant == ((old_quadrant - 1) & 0x03)) {
    // Case 4: Moved to previous quadrant.
    isr_update_full_steps_counter(-1);
    isr_add_step_to_histogram(old_quadrant, isr_data.state.last_step_direction,
                              BACKWARD, isr_data.state.ticks_in_step,
                              isr_data.state.max_current_in_step);
    isr_data.state.last_step_direction = BACKWARD;
    isr_data.state.ticks_in_step = 1;
    isr_data.state.max_current_in_step = max_current;
  } else {
    // Case 5: Invalid quadrant transition.
    // TODO: count and report errors.
    isr_data.state.quadrature_errors++;
    isr_data.state.last_step_direction = UNKNOWN_DIRECTION;
    isr_data.state.ticks_in_step = 1;
    isr_data.state.max_current_in_step = max_current;
  }
}



// An ISR that is called after a predefined number of calls to
// isr_handle_one_sample. Used to snapshot the state at fixed time intervals.
void isr_snapshot_state() {
  // This drops the oldest entry if buffer becomes full.
  State* entry = state_circular_buffer.insert();
  *entry = isr_data.state;
  // Notify the notification thread that a new state is available.
  // k_sem_give(&circular_state_semaphore);
  xSemaphoreGive(circular_state_semaphore);
}

// Force a reasonable offset setting value.
static int clip_offset(int requested_offset) {
  return (requested_offset > kMaxOffset)   ? kMaxOffset
         : (requested_offset < kMinOffset) ? kMinOffset
                                           : requested_offset;
}

// Call once on program initialization, before ADC interrupts are
// enabled.
void setup(const Settings& settings) {
  data_mutex = xSemaphoreCreateMutex();
  assert(data_mutex);

  circular_state_semaphore =
      xSemaphoreCreateCounting(state_circular_buffer.capacity, 0);
  assert(circular_state_semaphore);

  ENTER_MUTEX {
    // adc_dma::disable_irq();

    isr_data.adc_capture_state = ADC_CAPTURE_HALF_FILL;
    isr_data.adc_capture_divider = 1;

    isr_data.offset1 = clip_offset(settings.offset1);
    isr_data.offset2 = clip_offset(settings.offset2);
    isr_data.state.is_reverse_direction = settings.is_reverse_direction;

    // We reset the capture without incrementing the capture
    // sequence number since we didn't completed it.
    isr_reset_adc_capture_buffer();

    // adc_dma::enable_irq();
  }
  EXIT_MUTEX
}

// This involves floating point operations and thus slow. Do not
// call from the interrupt routine.
//
// NOTE: ISR may also have an issue with not saving FP regiaters.
double state_steps(const State& state) {
  // If not energized, we can't compute fractional steps.
  if (!state.is_energized) {
    return state.full_steps;
  }

  // Compute fractional stept. We use the abs() to avoid
  // the discontinuity near -180 degrees. It provides better safety with
  // the non determinism of floating point values.
  // Range is in [0, PI];
  const double radians = atan2((double)state.v2, (double)state.v1);
  const double abs_radians = fabs(radians);

  // printk("atan2: %hd, %hd -> %f, %f\n\n", state.v2, state.v1, radians,
  // abs_radians);

  // Rel radians in [-PI/4, PI/4].
  double rel_radians = 0;
  switch (state.quadrant) {
    case 0:
      rel_radians = abs_radians - (M_PI / 4);
      break;
    case 1:
      rel_radians = abs_radians - (3 * M_PI / 4);
      break;
    case 2:
      rel_radians = (3 * M_PI / 4) - abs_radians;
      break;
    case 3:
      rel_radians = (M_PI / 4) - abs_radians;
      break;
  }

  // Fraction is in the range [-0.5, 0.5]
  const double fraction = rel_radians * (2 / M_PI);

  const double result = state.is_reverse_direction
                            ? state.full_steps - fraction
                            : state.full_steps + fraction;

  return result;
}

}  // namespace analyzer
