
#pragma once

#include <stdint.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

namespace util {

// Done in increments of RTOS ticks (10ms)
// inline void delay_ms(uint32_t ms) { vTaskDelay(pdMS_TO_TICKS(ms)); }

// // Time in RTOS ticks (100Hz)
// inline uint32_t rtos_ticks() { return xTaskGetTickCount(); }

// // Returned millis are in increments of RTOS tickes (10ms).
// inline uint32_t time_ms() { return pdTICKS_TO_MS(xTaskGetTickCount()); }

// inline uint64_t time_us() { return (uint64_t)esp_timer_get_time(); }

// Do not enable in normal operation. Blocks interrupts.
// void dump_tasks();

void nvs_init();

}  // namespace util