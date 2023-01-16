// API of the data acquisition and step decoder modole. This
// is the core of the analysis software and it is executed
// in an interrupt routine so handle with care.

#pragma once

#include <string.h>

#include "acq_consts.h"
#include "misc/circular_buffer.h"

namespace analyzer {

// This is set in the Settings page.
struct Settings {
  // Offsets to substract from the ADC readings to have zero reading
  // when the current is zero.
  // Typically around ~1900 which represents ~1.5V from the current
  // sensors.
  int16_t offset1;
  int16_t offset2;
  // If true, reverse interpretation of forward/backward movement.
  bool is_reverse_direction;
};

// Number of pairs of ADC readings to capture for the signal
// capture page. The capture logic try to sync a ch1 up crossing
// the horizontal axis at the middle of the buffer for better
// visual stability.
//
// NOTE: When sending the data packet through BLE, each sample
// consumes 4 bytes so make sure to to exceed to the BLE MTU.
//
// TODO: Consider compressing the BLE packet to increase the point
// count.

// @@@ Should be 400 for compatibility with nrf52.
// constexpr uint16_t kAdcCaptureBufferSize = 400;
constexpr uint16_t kAdcCaptureBufferSize = 500;

// Number of captured samples to wait for a trigger. If this number
// of samples is reached, we force a trigger.
constexpr uint16_t kAdcCaptureMaxWaitToTrigger = kAdcCaptureBufferSize;

// A single captured item. These are the signed values
// in adc counts of the two curent sensing channels.
struct AdcCaptureItem {
  AdcCaptureItem() : v1(0), v2(0) {}
  // Coil currents in adc tick units.
  int16_t v1;
  int16_t v2;
};

// A circular array with captured signals. Using a circular array
// allow to capture data before the trigger point.
typedef CircularBuffer<AdcCaptureItem, kAdcCaptureBufferSize> AdcCaptureItems;

struct AdcCaptureBuffer {
  AdcCaptureBuffer() : seq_number(0), divider(1){};
  // Incremented on each capture snapshot. Users should handle
  // overflow gracefully.
  uint16_t seq_number;
  // Indcates the X time divider >= 1. Value of 1 indicates all
  // samples are included. Value of 2 indicates every other sample
  // is included and so on.
  uint8_t divider;

  // The actual items as a circular buffer.
  AdcCaptureItems items;
};

// Max number of capture steps items. Stpes are captures at
// a slow rate so a small number is suffient for the
// UI to catch up considering the worst case screen update
// time.
constexpr uint32_t kStepsCaptureBufferSize = 10;

constexpr uint32_t kStepsCaptursPerSec = 20;

struct StepsCaptureItem {
  // Snapshots of the corresponding fields in State object.
  int full_steps;
  int max_full_steps;
};

// We collect the samples in a circular buffer so we can send them
// through notifications to the BLE client without loosing any.
typedef CircularBuffer<StepsCaptureItem, kStepsCaptureBufferSize>
    StepsCaptureBuffer;

// Step direction classification. The analyzer classifies
// each step with these gats. Unknown happens when direction
// is reversed at the middle of the step.
enum Direction { UNKNOWN_DIRECTION, FORWARD, BACKWARD };

// A single histogram bucket
struct HistogramBucket {
  // Total adc samples in steps in this bucket. This is a proxy
  // for time spent in this speed range.
  uint64_t total_ticks_in_steps;
  // Total max step current in ADC counts. Used
  // to compute the average max coil curent by speed range.
  uint64_t total_step_peak_currents;
  // Total steps. This is a proxy for the distance (in either direction)
  // done in this speed range.
  uint32_t total_steps;
};

// Analyzer state. Does not include signal captures and histogram.
// Snapshots of this values are used to generates the BLE state
// notification.
struct State {
  State()
      : tick_count(0),
        ticks_with_errors(0),
        v1(0),
        v2(0),
        is_energized(false),
        non_energized_count(0),
        quadrant(0),
        is_reverse_direction(false),
        full_steps(0),
        max_full_steps(0),
        max_retraction_steps(0),
        quadrature_errors(0),
        last_step_direction(UNKNOWN_DIRECTION),
        max_current_in_step(0),
        ticks_in_step(0) {}

  // Number of ADC pair samples since last data reset. This is
  // also a proxy for the time passed. The number of time ticks
  // per second is TIME_TICKS_PER_SEC.
  uint64_t tick_count;

  // Ticks that have the ADC error flag set.
  uint32_t ticks_with_errors;

  // Signed current values in ADC count units.  When the stepper
  // is energized, these values together with the quadrant value
  // below can be used to compute the fractional step value.
  // This value has ADC_TICKS_PER_AMP ticks per amp.
  int16_t v1;
  int16_t v2;
  // True if the coils are energized. Determined by the sum
  // of the absolute values of a pair of current readings.
  //
  // NOTE: The energized detection and count doesn't work well
  // with noisy current sensors.
  bool is_energized;
  // Number of times coils were de-energized.
  uint32_t non_energized_count;
  // The last quadrant in the range [0, 3]. Each quadrant
  // represents a full step. See quadrants_plot.png  for details.
  uint8_t quadrant;
  // If true, direction is interpreted in the reversed direction.
  // This flag is needed to calculate the fractional step value
  // from quadrart, full_steps, and v1, v2.
  bool is_reverse_direction;
  // Total (forward - backward) full steps. This is a proxy
  // for the overall distance.
  int full_steps;
  // Max value of full_steps so far. Momentary retraction value
  // can computed as max(0, max_full_steps - full_steps).
  int max_full_steps;
  // Max value of (max_full_steps - full_steps). As of Jan 2021,
  // this value is computed but not used.
  int max_retraction_steps;
  // Total invalid quadrant transitions. Typically indicate
  // distorted stepper coils current patterns.
  uint32_t quadrature_errors;
  // Direction of last step. Used to track step speed.
  Direction last_step_direction;
  // Max current detected in the current step. We use a single non signed
  // value for both channels. in ADC count units.
  uint32_t max_current_in_step;
  // Time in current state, in 100Khz ADC sample time unit. This is
  // a proxy for the time in current step.
  uint32_t ticks_in_step;
};

struct Histogram {
  Histogram() { memset(buckets, 0, sizeof(buckets)); }
  // Histogram, each bucket represents a range of steps/sec speeds.
  HistogramBucket buckets[acq_consts::kNumHistogramBuckets];
};

// Helpers for dumping aquisition sate. For debugging.
void dump_state(const State& state);
void dump_adc_capture_buffer(const AdcCaptureBuffer& adc_capture_buffer);

// Called once during program initialization, before enabling
// ADC interrupts.
void setup(const Settings& settings);

void get_last_capture_snapshot(AdcCaptureBuffer* buffer);

// Sample histogram. Does not resets or mutate the
// histogram tracking.
void sample_histogram(Histogram* histogram);

// Sample capture steps items since last call to this function.
// Returns a pointer to an internal buffer with the consumed
// items, if any.
const StepsCaptureBuffer* sample_steps_capture();

// Sample the current state into given buffer.
void sample_state(State* state);

// For notification. Blocking.
bool pop_next_state(State* state);

// Clears state and histogram data. This resets counters, min/max values,
// histograms, etc. This does not reset the tick counter
// which provides a consistent time base since initialization, nor the
// capture buffer.
void reset_data();

// Return the steps value of the given state.
double state_steps(const State& state);

// Call this when the coil current is known to be zero to
// calibrate the internal offset1 and offset2.
void calibrate_zeros();

// Set direction. This updates the current settings.
// Controlled by the user in the Settings screen.
void set_is_reversed_direction(bool is_reverse_direction);

bool get_is_reversed_direction();

// Clipped internally to allowed range.
void set_signal_capture_divider(uint8_t divider);

// Return a copy of the internal settings. Used after
// calibrate_zeros() to save the current settings in the
// EEPROM.
void get_settings(Settings* settings);

// Temp
void dump_dma_state();

}  // namespace analyzer
