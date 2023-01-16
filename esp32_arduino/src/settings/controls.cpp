

#include "controls.h"

// #include <zephyr.h>
#include <stdio.h>

#include "acquisition/analyzer.h"
#include "esp_log.h"
#include "settings/nvs_config.h"

namespace controls {

static constexpr auto TAG = "config";

bool zero_calibration() {
  analyzer::calibrate_zeros();
  analyzer::Settings settings;
  analyzer::get_settings(&settings);
  const bool write_ok = nvs_config::write_acquisition_settings(settings);
  ESP_LOGI(TAG, "Zero calibration (%hd, %hd). Write %s", settings.offset1,
           settings.offset2, write_ok ? "OK" : "FAILED");
  return write_ok;
}

// Ok for new_reversed_direction to be null.
bool toggle_direction(bool* new_reversed_direction) {
  const bool new_direction = !analyzer::get_is_reversed_direction();
  analyzer::set_is_reversed_direction(new_direction);
  if (new_reversed_direction) {
    *new_reversed_direction = new_direction;
  }
  // We also reset the steps counter and such.
  analyzer::reset_data();
  analyzer::Settings settings;
  analyzer::get_settings(&settings);
  const bool write_ok = nvs_config::write_acquisition_settings(settings);
  ESP_LOGI(TAG, "%s direction. Write %s", new_direction ? "REVERSED" : "NORMAL",
           write_ok ? "OK" : "FAILED");
  return write_ok;
}
}  // namespace controls
