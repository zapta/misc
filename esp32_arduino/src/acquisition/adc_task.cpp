

#include "adc_task.h"

#include <stdio.h>

#include "analyzer_private.h"
#include "driver/adc.h"
#include "esp_assert.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"
#include "freertos/task.h"
#include "io/io.h"
#include "misc/elapsed.h"
#include "sdkconfig.h"

namespace adc_task {

static constexpr auto TAG = "adc_task";

constexpr uint32_t kBytesPerValue = sizeof(adc_digi_output_data_t);
constexpr uint32_t kValuePairsPerBuffer = 50;
constexpr uint32_t kValuesPerBuffer = 2 * kValuePairsPerBuffer;
constexpr uint32_t kBytesPerBuffer = kValuesPerBuffer * kBytesPerValue;
constexpr uint32_t kNumBuffers = 2000 / kValuePairsPerBuffer;

#if !CONFIG_IDF_TARGET_ESP32
#error "Unexpected target CPU."
#endif

static const adc_digi_init_config_t adc_dma_config = {
    .max_store_buf_size = kNumBuffers * kBytesPerBuffer,
    .conv_num_each_intr = kBytesPerBuffer,
    .adc1_chan_mask = BIT(6) | BIT(7),
    .adc2_chan_mask = 0,
};

// TODO: Ok to have only two entries in this array instead
// of SOC_ADC_PATT_LEN_MAX?
static adc_digi_pattern_config_t adc_pattern[] = {
    {
        .atten = ADC_ATTEN_DB_11,
        .channel = 6,
        .unit = 0,  /// ADC_UNIT_1,
        .bit_width = SOC_ADC_DIGI_MAX_BITWIDTH,
    },
    {
        .atten = ADC_ATTEN_DB_11,
        .channel = 7,
        .unit = 0,  // ADC_UNIT_1,
        .bit_width = SOC_ADC_DIGI_MAX_BITWIDTH,
    },
};

static const adc_digi_configuration_t dig_cfg = {
    .conv_limit_en = 1,
    // .conv_limit_num = 255,
    .conv_limit_num = 200,

    .pattern_num = 2,
    .adc_pattern = adc_pattern,

    // 40k sample pairs per sec.
    // ESP32 range is 611Hz ~ 83333Hz
    .sample_freq_hz = 80 * 1000,
    .conv_mode = ADC_CONV_SINGLE_UNIT_1,
    .format = ADC_DIGI_OUTPUT_FORMAT_TYPE1,
};

static uint8_t buffer_bytes[kBytesPerBuffer] = {0};

struct AdcTaskStats {
  uint64_t good_67_pairs;
  uint64_t good_76_pairs;
  uint32_t bad_pairs;
};

static SemaphoreHandle_t stats_mutex;
static AdcTaskStats stats = {};

void dump_stats() {
  AdcTaskStats snapshot;
  xSemaphoreTake(stats_mutex, portMAX_DELAY);
  { snapshot = stats; }
  xSemaphoreGive(stats_mutex);
  ESP_LOGI(TAG, "bad: %u, good: %llu, good_swap: %llu", snapshot.bad_pairs,
           stats.good_67_pairs, stats.good_76_pairs);
}

// Accepts a pair of samples, sort them to v1 and v2 and return true,
// or returns false, if can't.
// Called within stats mutex.
inline bool mutex_condition_sample_pair(const adc_digi_output_data_t& data1,
                                        const adc_digi_output_data_t& data2,
                                        uint16_t* v1, uint16_t* v2) {
  if (data1.type1.channel == 6 && data2.type1.channel == 7) {
    *v1 = data1.type1.data;
    *v2 = data2.type1.data;
    stats.good_67_pairs++;
    return true;
  }

  if (data1.type1.channel == 7 && data2.type1.channel == 6) {
    *v1 = data2.type1.data;
    *v2 = data1.type1.data;
    stats.good_76_pairs++;
    return true;
  }

  stats.bad_pairs++;
  return false;
}

void adc_task(void* ignored) {
  // bool in_order = false;
  // uint32_t order_changes = 0;
  uint32_t buffers_count = 0;
  uint32_t samples_to_snapshot = 0;
  // Elapsed timer;

  for (;;) {
    io::TEST1.clear();
    uint32_t num_ret_bytes = 0;
    esp_err_t err_code = adc_digi_read_bytes(buffer_bytes, kBytesPerBuffer,
                                             &num_ret_bytes, ADC_MAX_DELAY);
    io::TEST1.set();

    // Sanity check the results.
    if (err_code != ESP_OK || num_ret_bytes != kBytesPerBuffer) {
      ESP_LOGE(TAG, "ADC read failed: %0x %u", err_code, num_ret_bytes);
      assert(false);
    }

    adc_digi_output_data_t* buffer_values =
        (adc_digi_output_data_t*)&buffer_bytes;

    buffers_count++;

    // We expect the buffer to have the same order of pairs.
    analyzer::enter_mutex();
    xSemaphoreTake(stats_mutex, portMAX_DELAY);
    {
      for (int i = 0; i < kValuesPerBuffer; i += 2) {
        uint16_t v1;
        uint16_t v2;
        if (!mutex_condition_sample_pair(buffer_values[i], buffer_values[i + 1],
                                         &v1, &v2)) {
          // Bad pair. Skip.
          continue;
        }
        analyzer::isr_handle_one_sample(v1, v2);
      }
    }

    samples_to_snapshot += kValuePairsPerBuffer;
    if (samples_to_snapshot >= 800) {
      analyzer::isr_snapshot_state();
      samples_to_snapshot = 0;
    }
    xSemaphoreGive(stats_mutex);
    analyzer::exit_mutex();
  }
}

void setup() {
  stats_mutex = xSemaphoreCreateMutex();
  assert(stats_mutex);

  ESP_ERROR_CHECK(adc_digi_initialize(&adc_dma_config));
  ESP_ERROR_CHECK(adc_digi_controller_configure(&dig_cfg));
  ESP_ERROR_CHECK(adc_digi_start());

  TaskHandle_t xHandle = NULL;
  // Create the task, storing the handle.  Note that the passed parameter
  // ucParameterToPass must exist for the lifetime of the task, so in this case
  // is declared static.  If it was just an an automatic stack variable it might
  // no longer exist, or at least have been corrupted, by the time the new task
  // attempts to access it.
  xTaskCreate(adc_task, "ADC", 4000, nullptr, 10, &xHandle);
  configASSERT(xHandle);
}

}  // namespace adc_task
