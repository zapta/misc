#include "util.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "nvs.h"
#include "nvs_flash.h"
#include "esp_log.h"

namespace util {

static constexpr auto TAG = "analyzer";


static char text_buffer[600];

// https://www.freertos.org/uxTaskGetSystemState.html
// https://www.freertos.org/a00021.html#vTaskList
//
// NOTE: This disables interrupts throughout its
// operation. Do no use in normal operation.
// void dump_tasks() {
//   vTaskList(text_buffer);
//   printf("\n");
//   printf("Name          State    Prio     Free   ID\n");
//   printf("-----------------------------------------\n");
//   // NOTE: buffer requires up to 40 chars per task.
//   printf("%s\n", text_buffer);
// }

void nvs_init() {
  esp_err_t err = nvs_flash_init();
  if (err == ESP_OK) {
    ESP_LOGI(TAG, "nvs_flash_init() ok.");
    return;
  }

  // This is the initial creation in new devices.
  if (err == ESP_ERR_NVS_NO_FREE_PAGES ||
      err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
    ESP_LOGW(TAG, "nvs_flash_init() err %04x. Erasing nvs...", err);
    // This should not fail.
    ESP_ERROR_CHECK(nvs_flash_erase());
    ESP_LOGI(TAG, "nvs erased. Initializing again...");
    // This should not fail.
    ESP_ERROR_CHECK(nvs_flash_init());
    ESP_LOGI(TAG, "nvs_flash_init() ok.");
    return;
  }

  ESP_LOGE(TAG, "nvs_flash_init() fatal error %04x.", err);
  assert(false);
}

}  // namespace util