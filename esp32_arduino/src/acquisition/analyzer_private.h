// Private analyzer API for the ADC task.
#pragma once

#include <string.h>

namespace analyzer {

void enter_mutex();
void exit_mutex();

void isr_handle_one_sample(const uint16_t raw_v1, const uint16_t raw_v2);
void isr_snapshot_state();

}  // namespace analyzer
