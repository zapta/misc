#pragma once

#include <stdint.h>

namespace acq_consts {

// Sensor sensitivity in mv/A. From the datasheets.
constexpr uint16_t CC6920BSO5A_MV_PER_AMP = 270;
constexpr uint16_t TMCS1108A4B_MV_PER_AMP = 400;

// ADC ticks per 1A current.
// 4096 and 3300 are ADC full scale ticks and mv respectivly.
constexpr uint16_t xCC6920BSO5A_ADC_TICKS_PER_AMP =
    (4096 * CC6920BSO5A_MV_PER_AMP) / 3300;
constexpr uint16_t xTMCS1108A4B_ADC_TICKS_PER_AMP =
    (4096 * TMCS1108A4B_MV_PER_AMP) / 3300;

// How many time the pair of channels is sampled per second.
// This time ticks are used as the data time base.
constexpr uint32_t TIME_TICKS_PER_SEC = 40000;

// Number of histogram buckets, each bucket represents
// a band of step speeds.
constexpr int kNumHistogramBuckets = 25;

// Each histogram bucket represents a speed range of 100
// steps/sec, starting from zero. Overflow speeds are
// aggregated in the last bucket.
const int kBucketStepsPerSecond = 200;

}  // namespace acq_consts