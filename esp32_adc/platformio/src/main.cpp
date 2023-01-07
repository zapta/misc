// #include <string.h>

// #include "acquisition/adc_task.h"
// #include "acquisition/analyzer.h"
#include "esp_event.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

// #include "misc/elapsed.h"
// #include "esp_log.h"
#include "driver/adc.h"
#include "esp_system.h"
#include "sdkconfig.h"

// #include "esp_wifi.h"
// #include "ble/ble_service.h"
#include "driver/ledc.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
// #include "io/io.h"
// #include "misc/util.h"

// #include "lwip/err.h"
// #include "lwip/sys.h"
// #include "nvs_flash.h"

#include <stdio.h>

#include "driver/gpio.h"
#include "esp_system.h"

// #include "nvs.h"
// #include "nvs_flash.h"

// #define STORAGE_NAMESPACE "storage"

// #define TAG "main"

// Should be equivalent to sizeof(*adc_digi_output_data_t)
constexpr uint32_t kBytesPerValue = 2;

// Number of pairs of samples per a read packet.
constexpr uint32_t kValuePairsPerBuffer = 50;

constexpr uint32_t kValuesPerBuffer = 2 * kValuePairsPerBuffer;

// Number of buffer bytes per a read packet.
// Increasing this value 'too much' causes in stability (with IDF 4.4.3).
constexpr uint32_t kBytesPerBuffer = kValuesPerBuffer * kBytesPerValue;

// Num of buffer in the ADC/DMA circular queue. We want to have
// a sufficient size to allow backlog in processing.
constexpr uint32_t kNumBuffers = 8;

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
        .unit = 0,  /// ADC_UNIT_1,
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

static uint8_t bytes_buffer[kBytesPerBuffer] = {0};

// void test_nvs() {
//   nvs_handle_t my_handle;
//   esp_err_t err;

//   // Open
//   printf("Opening...\n");
//   err = nvs_open(STORAGE_NAMESPACE, NVS_READWRITE, &my_handle);
//   ESP_ERROR_CHECK(err);
//   printf("Opened.\n");

//   // if (err != ESP_OK) {
//   // }
//   // return err;

//   // Read
//   printf("Reading...\n");
//   int32_t offset_v1 = 0;  // value will default to 0, if not set yet in NVS
//   err = nvs_get_i32(my_handle, "offset_v1", &offset_v1);
//   if (err != ESP_OK && err != ESP_ERR_NVS_NOT_FOUND) {
//     ESP_ERROR_CHECK(err);
//   }
//   printf("Read %d\n", offset_v1);

//   // Write
//   offset_v1++;
//   printf("Wrting %d ...\n", offset_v1);

//   err = nvs_set_i32(my_handle, "offset_v1", offset_v1);
//   ESP_ERROR_CHECK(err);
//   printf("Written\n");

//   // Commit written value.
//   // After setting any values, nvs_commit() must be called to ensure changes
//   are
//   // written to flash storage. Implementations may write to storage at other
//   // times, but this is not guaranteed.
//   printf("Comitting...\n");

//   err = nvs_commit(my_handle);
//   ESP_ERROR_CHECK(err);
//   printf("Commited\n");

//   // Close
//   printf("Closing...\n");

//   nvs_close(my_handle);
//   printf("Closed\n");

//   // return ESP_OK;
// }

static const ledc_timer_config_t ledc_timer = {
    .speed_mode = LEDC_LOW_SPEED_MODE,
    .duty_resolution = LEDC_TIMER_13_BIT,
    .timer_num = LEDC_TIMER_0,
    .freq_hz = 1000,
    .clk_cfg = LEDC_AUTO_CLK};

static const ledc_channel_config_t ledc_channel = {
    .gpio_num = 32,
    .speed_mode = LEDC_LOW_SPEED_MODE,
    .channel = LEDC_CHANNEL_0,
    .intr_type = LEDC_INTR_DISABLE,
    .timer_sel = LEDC_TIMER_0,
    .duty = 8191 / 2,
    .hpoint = 0,
    .flags = {
        .output_invert = 0,
    }};

static void init_pwm() {
  ESP_ERROR_CHECK(ledc_timer_config(&ledc_timer));
  ESP_ERROR_CHECK(ledc_channel_config(&ledc_channel));
}

// class A {
//  public:
//   A(int val) : val_(val) {}
//   int val_;
// };

// A a1(11);
// int b = 123;

// static analyzer::State state;

// static analyzer::AdcCaptureBuffer capture_buffer;

void my_main() {
  init_pwm();

  ESP_ERROR_CHECK(adc_digi_initialize(&adc_dma_config));
  ESP_ERROR_CHECK(adc_digi_controller_configure(&dig_cfg));
  ESP_ERROR_CHECK(adc_digi_start());

  //for (;;) {
    // io::TEST1.clear();
    // esp_err_t err_code;

    // A few seconds of adc reads as a delay.
    for (int i = 0; i < 100; i++) {
      uint32_t num_ret_bytes = -1;
      const esp_err_t err_code = adc_digi_read_bytes(
          bytes_buffer, kBytesPerBuffer, &num_ret_bytes, ADC_MAX_DELAY);
      if (err_code != ESP_OK) {
        printf("Error 0x%x\n", err_code);
        assert(false);
      }
      assert(num_ret_bytes == kBytesPerBuffer);
    }

    // Dump 5 buffers as groups of High/Low values.
    char pending_char = '?';
    int pending_char_count = 0;
    int toggles = 0;
    printf("\n");
    for (int i = 0; i < kNumBuffers; i++) {
      uint32_t num_ret_bytes = -1;
      const esp_err_t err_code = adc_digi_read_bytes(
          bytes_buffer, kBytesPerBuffer, &num_ret_bytes, ADC_MAX_DELAY);
      ESP_ERROR_CHECK(err_code);
      assert(num_ret_bytes == kBytesPerBuffer);

      const adc_digi_output_data_t *values =
          (adc_digi_output_data_t *)&bytes_buffer;
      for (int j = 0; j < kValuesPerBuffer; j += 2) {
        const char new_char = values[j].type1.data > 2000 ? 'H' : 'L';
        if (new_char != pending_char) {
          // Don't print first group since it can be partial.
          if (toggles > 1) {
            printf("* %c %3d\n", pending_char, pending_char_count);
          }
          toggles++;
          pending_char = new_char;
          pending_char_count = 1;
        } else {
          pending_char_count++;
        }
      }
    }
    // NOTE: we don't print the last group since it can be partial.

    // if (pending_char_count > 0) {
    //   printf("* %c %3d\n\n", pending_char, pending_char_count);
    // }

    printf("\nTest completed. Reset to rerun\n");

    for(;;) {
      vTaskDelay(10);
    }

    // Read a few buffers, ignoring the status, in case
    // the queue is overrun due to the slow prints above.
    // Note that we ignore the status of adc_digi_read_bytes();
    // for (int i = 0; i < 50; i++) {
    //   uint32_t num_ret_bytes = -1;
    //   const esp_err_t err_code = adc_digi_read_bytes(
    //       bytes_buffer, kBytesPerBuffer, &num_ret_bytes, ADC_MAX_DELAY);
    // }

    // io::TEST1.set();

    // // Sanity check the results.
    // if (err_code != ESP_OK || num_ret_bytes != kBytesPerBuffer) {
    //   printf("ADC read failed: %0x %u\n", err_code, num_ret_bytes);
    //   assert(false);
    // }

    // buffers_count++;
    // adc_digi_output_data_t *values = (adc_digi_output_data_t *)&bytes_buffer;

    // if (buffers_count % 400 == 0) {
    //   printf("%d\n", buffers_count);
    // }

    // if (values[0].type1.channel == 6) {
    //   assert(values[1].type1.channel == 7);
    //   if (!in_order) {
    //     in_order = true;
    //     order_changes++;
    //   }

    // } else {
    //   assert(values[0].type1.channel == 7);
    //   assert(values[1].type1.channel == 6);
    //   if (in_order) {
    //     in_order = false;
    //     order_changes++;
    //   }
    // }

    // if (timer.elapsed_millis() >= 10000) {
    //   timer.reset();
    //   printf("ADC: %s, [%4u, %4u]  %u, %u\n", (in_order ? "[6,7]" : "[7,6]"),
    //          values[0].type1.data, values[1].type1.data, order_changes,
    //          buffers_count);
    // }

    // printf("%hu %hu %4hu %4hu\n", values[0].type1.channel,
    //        values[1].type1.channel, values[0].type1.data,
    //        values[1].type1.data);

    // We expect the buffer to have the same order of pairs.
    // analyzer::enter_mutex();
    // {
    //   for (int i = 0; i < kValuePairsPerBuffer; i += 2) {
    //     if (in_order) {
    //       analyzer::isr_handle_one_sample(values[i].type1.data,
    //                                       values[i + 1].type1.data);
    //     } else {
    //       analyzer::isr_handle_one_sample(values[i + 1].type1.data,
    //                                       values[i].type1.data);
    //     }

    //     bool ok = (values[i].type1.channel == (in_order ? 6 : 7)) &&
    //               (values[i + 1].type1.channel == (in_order ? 7 : 6));
    //     if (!ok) {
    //       printf("\n----\n\n");
    //       for (int j = 0; j < kValuePairsPerBuffer; j += 2) {
    //         printf("%3d: %hu %4hu %hu %4hu\n", j, values[j +
    //         0].type1.channel,
    //                values[j + 0].type1.data, values[j + 1].type1.channel,
    //                values[j + 1].type1.data);
    //       }

    //       for (;;) {
    //         vTaskDelay(1);
    //       }
    //     }
    //   }
    // }

    // samples_to_snapshot+= kValuePairsPerBuffer;
    // if (samples_to_snapshot >= 800) {
    //   analyzer::isr_snapshot_state();
    //   samples_to_snapshot = 0;
    // }

    // analyzer::exit_mutex();
  // }

  // analyzer::Settings settings = {.offset1 = 2000 - 188,
  //                                .offset2 = 2000 - 230,
  //                                .is_reverse_direction = false};
  // analyzer::setup(settings);
  // adc_task::setup();

  //------------
  // for (int iter = 0;; iter++) {
  //   // Blocking.
  //   analyzer::pop_next_state(&state);

  //   // Dump state
  //   if (iter % 100 == 0) {
  //     analyzer::dump_state(state);
  //   }
  //   // Dump capture buffer
  //   if (iter % 500 == 0) {
  //     analyzer::get_last_capture_snapshot(&capture_buffer);
  //     char prev_char = '?';
  //     int prev_count = 0;
  //     for (int i = 0; i < capture_buffer.items.size(); i++) {
  //       const analyzer::AdcCaptureItem* item = capture_buffer.items.get(i);
  //       const char new_char = item->v1 < -1000  ? 'L'
  //                             : item->v1 > 1000 ? 'H'
  //                                               : 'X';
  //       if (new_char == prev_char) {
  //         prev_count++;
  //       } else {
  //         if (prev_count > 0) {
  //           printf("+ %c %03d\n", prev_char, prev_count);
  //         }
  //         prev_char = new_char;
  //         prev_count = 1;
  //       }
  //       // printf("%5hd %s\n", item->v1, item->v1 < 0 ? "**" : "******");
  //     }
  //     printf("+ %c %03d\n", prev_char, prev_count);

  //     // analyzer::dump_adc_capture_buffer(capture_buffer);
  //   }
  // }
  // return;
  //--------------

  // ble_service::test();

  // for (;;) {
  //   A a2(22);
  //   printf("a1.val_=%d, a2.val_=%d, b=%d\n", a1.val_, a2.val_, b);
  //   sys_delay_ms(1000);
  // }

  // printf("Initializing...\n");
  // esp_err_t err = nvs_flash_init();
  // if (err == ESP_ERR_NVS_NO_FREE_PAGES ||
  //     err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
  //   printf("Need to create...\n");

  //   // NVS partition was truncated and needs to be erased
  //   // Retry nvs_flash_init
  //   ESP_ERROR_CHECK(nvs_flash_erase());
  //   err = nvs_flash_init();
  // }
  // ESP_ERROR_CHECK(err);
  // printf("Storage ok\n");

  // for (;;) {
  //   // Yields to avoid starvations and WDT trigger.
  //   util::delay_ms(10);
  //   Button::ButtonEvent event = io::BUTTON1.update();

  //   io::LED1.write(io::BUTTON1.is_pressed());
  //   if (event != Button::EVENT_NONE) {
  //     printf("Event: %d\n", event);
  //   }

  //   // sys_delay_ms(1000);

  //   // io::LED1.toggle();

  //   // vTaskDelay(pdMS_TO_TICKS(1000));
  //   // util::delay_ms(1000);

  //   // io::LED1.toggle();
  //   // io::LED2.toggle();

  //   // util::delay_ms(1000);

  //   // uint64_t t0 = util::time_us();
  //   // uint32_t ms = util::time_ms();
  //   // uint64_t t1 = util::time_us();
  //   // printf("dt=%u %u\n", (uint32_t)(t1 - t0), ms);
  // }
}

// The runtime environment expects a "C" main.
extern "C" void app_main() { my_main(); }
