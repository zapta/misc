
#include "settings/nvs_config.h"

#include <memory.h>
#include <rom/crc.h>
#include <stdio.h>

#include "esp_log.h"
#include "nvs.h"
#include "nvs_flash.h"

namespace nvs_config {

static constexpr auto TAG = "nvs_config";

static constexpr auto kStorageNamespace = "settings";


// void setup() {
//   esp_err_t err = nvs_flash_init();
//   if (err == ESP_OK) {
//     ESP_LOGI(TAG, "nvs_flash_init() ok.");
//     return;
//   }

//   // This is the initial creation in new devices.
//   if (err == ESP_ERR_NVS_NO_FREE_PAGES ||
//       err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
//     ESP_LOGW(TAG, "nvs_flash_init() err %04x. Erasing nvs...", err);
//     // This should not fail.
//     ESP_ERROR_CHECK(nvs_flash_erase());
//     ESP_LOGI(TAG, "nvs erased. Initializing again...");
//     // This should not fail.
//     ESP_ERROR_CHECK(nvs_flash_init());
//     ESP_LOGI(TAG, "nvs_flash_init() ok.");
//     return;
//   }

//   ESP_LOGE(TAG, "nvs_flash_init() fatal error %04x.", err);
//   assert(false);
// }

bool read_acquisition_settings(analyzer::Settings* settings) {
  // Open
  nvs_handle_t my_handle = -1;
  bool need_to_close = false;
  esp_err_t err = nvs_open(kStorageNamespace, NVS_READONLY, &my_handle);
  if (err != ESP_OK) {
    ESP_LOGW(TAG, "read_settings() failed to open nvs: %04x", err);
  } else {
    need_to_close = true;
  }

  // Read offset1.
  int16_t offset1;
  if (err == ESP_OK) {
    err = nvs_get_i16(my_handle, "offset1", &offset1);
    if (err != ESP_OK) {
      ESP_LOGW(TAG, "read_settings() failed read offset1: %04x", err);
    }
  }

  // Read offset 2.
  int16_t offset2;
  if (err == ESP_OK) {
    err = nvs_get_i16(my_handle, "offset2", &offset2);
    if (err != ESP_OK) {
      ESP_LOGW(TAG, "read_settings() failed read offset2: %04x", err);
    }
  }

  // Read is_reverse flag.
  uint8_t is_reverse_direction;
  if (err == ESP_OK) {
    err = nvs_get_u8(my_handle, "is_reverse", &is_reverse_direction);
    if (err != ESP_OK) {
      ESP_LOGW(TAG, "read_settings() failed read is_reverse: %04x", err);
    }
  }

  // Close.
  if (need_to_close) {
    nvs_close(my_handle);
  }

  // Handle results.
  if (err != ESP_OK) {
    return false;
  }
  settings->offset1 = offset1;
  settings->offset2 = offset2;
  settings->is_reverse_direction = (bool)is_reverse_direction;
  return true;
}

bool write_acquisition_settings(const analyzer::Settings& settings) {
  // Open
  nvs_handle_t my_handle = -1;
  bool need_to_close = false;
  esp_err_t err = nvs_open(kStorageNamespace, NVS_READWRITE, &my_handle);
  if (err != ESP_OK) {
    ESP_LOGE(TAG, "write_settings() failed to open nvs: %04x", err);
  } else {
    need_to_close = true;
  }

  // Write offset1.
  if (err == ESP_OK) {
    err = nvs_set_i16(my_handle, "offset1", settings.offset1);
    if (err != ESP_OK) {
      ESP_LOGE(TAG, "write_settings() failed to write offset1: %04x", err);
    }
  }

  // Write offset2.
  if (err == ESP_OK) {
    err = nvs_set_i16(my_handle, "offset2", settings.offset2);
    if (err != ESP_OK) {
      ESP_LOGE(TAG, "write_settings() failed to write offset2: %04x", err);
    }
  }

  // Write is_reverse flag.
  if (err == ESP_OK) {
    err = nvs_set_u8(my_handle, "is_reverse",
                     settings.is_reverse_direction ? 0 : 1);
    if (err != ESP_OK) {
      ESP_LOGE(TAG, "write_settings() failed to write is_reverse: %04x", err);
    }
  }

  // Commit updates.
  if (err == ESP_OK) {
    err = nvs_commit(my_handle);
    if (err != ESP_OK) {
      ESP_LOGE(TAG, "write_settings() failed to commit: %04x", err);
    }
  }

  // Close.
  if (need_to_close) {
    nvs_close(my_handle);
  }
  return err == ESP_OK;
}

}  // namespace nvs_config