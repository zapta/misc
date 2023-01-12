
#include <stdio.h>
#include <string.h>

#include "driver/adc.h"
// #include "driver/ledc.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "sdkconfig.h"

constexpr uint32_t kBytesPerValue = sizeof(adc_digi_output_data_t);
constexpr uint32_t kValuePairsPerBuffer = 50;
constexpr uint32_t kValuesPerBuffer = 2 * kValuePairsPerBuffer;
constexpr uint32_t kBytesPerBuffer = kValuesPerBuffer * kBytesPerValue;

#if !CONFIG_IDF_TARGET_ESP32
#error "Unexpected target CPU."
#endif

static const adc_digi_init_config_t adc_dma_config = {
    .max_store_buf_size = 4 * kBytesPerBuffer,
    .conv_num_each_intr = kBytesPerBuffer,
    .adc1_chan_mask = BIT(6) | BIT(7),
    .adc2_chan_mask = 0,
};

// TODO: Ok to have only two entries in this array instead
// of SOC_ADC_PATT_LEN_MAX?
static adc_digi_pattern_config_t adc_pattern[SOC_ADC_PATT_LEN_MAX] = {
    {
        .atten = ADC_ATTEN_DB_11,
        .channel = 6,  // IO34
        .unit = 0,     // ADC_UNIT_1,
        .bit_width = SOC_ADC_DIGI_MAX_BITWIDTH,
    },
    {
        .atten = ADC_ATTEN_DB_11,
        .channel = 7,  // IO35
        .unit = 0,     // ADC_UNIT_1,
        .bit_width = SOC_ADC_DIGI_MAX_BITWIDTH,
    },
};

static const adc_digi_configuration_t dig_cfg = {
    .conv_limit_en = 1,
    .conv_limit_num = kBytesPerBuffer,
    .pattern_num = 2,
    .adc_pattern = adc_pattern,
    .sample_freq_hz = 80 * 1000,
    .conv_mode = ADC_CONV_SINGLE_UNIT_1,
    .format = ADC_DIGI_OUTPUT_FORMAT_TYPE1,
};

// static const ledc_timer_config_t ledc_timer = {
//     .speed_mode = LEDC_LOW_SPEED_MODE,
//     .duty_resolution = LEDC_TIMER_13_BIT,
//     .timer_num = LEDC_TIMER_0,
//     .freq_hz = 1000,
//     .clk_cfg = LEDC_AUTO_CLK};

// static const ledc_channel_config_t ledc_channel = {
//     .gpio_num = 32,
//     .speed_mode = LEDC_LOW_SPEED_MODE,
//     .channel = LEDC_CHANNEL_0,
//     .intr_type = LEDC_INTR_DISABLE,
//     .timer_sel = LEDC_TIMER_0,
//     .duty = 8191 / 2,
//     .hpoint = 0,
//     .flags = {
//         .output_invert = 0,
//     }};

// static void init_pwm() {
//   ESP_ERROR_CHECK(ledc_timer_config(&ledc_timer));
//   ESP_ERROR_CHECK(ledc_channel_config(&ledc_channel));
// }

static void init_adc_dma() {
  ESP_ERROR_CHECK(adc_digi_initialize(&adc_dma_config));
  ESP_ERROR_CHECK(adc_digi_controller_configure(&dig_cfg));
  ESP_ERROR_CHECK(adc_digi_start());
}

constexpr int kCaptureBuffers = 10;
constexpr int kCaptureValuePairs = kValuePairsPerBuffer * kCaptureBuffers;
constexpr int kCaptureValues = kValuesPerBuffer * kCaptureBuffers;
constexpr int kCaptureBytes = kBytesPerBuffer * kCaptureBuffers;
static uint8_t captured_buffers[kCaptureBytes] = {};
static int num_captured_buffers = 0;

void adc_task(void *ignored) {
  for (int i = 0;; i++) {
    uint32_t num_ret_bytes = -1;
    static uint8_t bytes_buffer[kBytesPerBuffer];
    const esp_err_t err_code = adc_digi_read_bytes(
        bytes_buffer, kBytesPerBuffer, &num_ret_bytes, ADC_MAX_DELAY);
    if (err_code != ESP_OK) {
      printf("Error 0x%x\n", err_code);
      assert(false);
    }
    assert(num_ret_bytes == kBytesPerBuffer);
    if (num_captured_buffers < kCaptureBuffers) {
      const int start = num_captured_buffers * kBytesPerBuffer;
      memcpy(&captured_buffers[start], bytes_buffer, kBytesPerBuffer);
      num_captured_buffers++;
    }
  }
}

// For Arduino serial plotter.
static void dump_adc_dma_buffers_as_graph() {
  // Assuming captured buffers are filled up.
  assert(num_captured_buffers == kCaptureBuffers);
  // printf("\n\n --------------------------\n");

  const adc_digi_output_data_t *values =
      (adc_digi_output_data_t *)&captured_buffers;
  for (int j = 0; j < kCaptureValues; j += 2) {
    const adc_digi_output_data_t &v1 = values[j];
    const adc_digi_output_data_t &v2 = values[j + 1];
    printf("%4u,%4u\n", v1.type1.data, v2.type1.data);
    // Satisfy WDT.
    if ((j & 0x0f) == 0) {
      vTaskDelay(1);
    }
  }
  // NOTE: we don't print the last group since it can be partial.
}

static void dump_adc_dma_buffers_as_values() {
  // Assuming captured buffers are filled up.
  assert(num_captured_buffers == kCaptureBuffers);
  printf("\n\n --------------------------\n");

  const adc_digi_output_data_t *values =
      (adc_digi_output_data_t *)&captured_buffers;
  for (int j = 0; j < kCaptureValues; j += 2) {
    const adc_digi_output_data_t &v1 = values[j];
    const adc_digi_output_data_t &v2 = values[j + 1];
    printf("%4d,%d,%d,%4u,%4u\n", j / 2, v1.type1.channel, v2.type1.channel,
           v1.type1.data, v2.type1.data);
    // Satisfy WDT.
    if ((j & 0x0f) == 0) {
      vTaskDelay(1);
    }
  }
  // NOTE: we don't print the last group since it can be partial.
}

static void dump_adc_dma_buffers_min_max() {
  // Assuming captured buffers are filled up.
  assert(num_captured_buffers == kCaptureBuffers);

  const adc_digi_output_data_t *values =
      (adc_digi_output_data_t *)&captured_buffers;
  uint32_t vmin = values[0].type1.data;
  uint32_t vmax = vmin;

  for (int j = 0; j < kCaptureValues; j += 2) {
    const adc_digi_output_data_t &v1 = values[j];
    const adc_digi_output_data_t &v2 = values[j + 1];
    assert(v1.type1.channel == 7);
    assert(v2.type1.channel == 6);
    if (v2.type1.data < vmin) vmin = v1.type1.data;
    if (v1.type1.data > vmax) vmax = v1.type1.data;
    // const adc_digi_output_data_t &v2 = values[j + 1];
    // printf("%d,%d,%4u,%4u\n", v1.type1.channel, v2.type1.channel,
    // v1.type1.data,
    //        v2.type1.data);
    // printf("%5d,%4hu\n", j, v1.type1.data);
  }

  printf("%d, min=%u, max=%u, diff=%u\n", kCaptureValuePairs, vmin, vmax,
         vmax - vmin);
  // NOTE: we don't print the last group since it can be partial.
}

void my_main() {
  // init_pwm();
  init_adc_dma();

  TaskHandle_t xHandle = NULL;
  xTaskCreate(adc_task, "ADC", 4000, nullptr, 10, &xHandle);
  configASSERT(xHandle);

  for (;;) {
    num_captured_buffers = 0;
    while (num_captured_buffers < kCaptureBuffers) {
      vTaskDelay(1);
    }
    dump_adc_dma_buffers_as_graph();
    // dump_adc_dma_buffers_as_values();
    // dump_adc_dma_buffers_min_max();

    vTaskDelay(100);  // 1 sec.
    // vTaskDelay(1000);  // 10 sec.
  }
}

// The runtime environment expects a "C" main.
extern "C" void app_main() { my_main(); }
