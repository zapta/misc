
#include "io.h"

#include "driver/gpio.h"

namespace io {

// Digital outputs.
OutputPin LED1(GPIO_NUM_26, 1);
OutputPin LED2(GPIO_NUM_25, 1);

OutputPin TEST1(GPIO_NUM_2, 0);

// Digital inputs.
static InputPin SWITCH1(GPIO_NUM_27, GPIO_PULLUP_ONLY);
Button BUTTON1(SWITCH1);

static InputPin CFG1(GPIO_NUM_18, GPIO_PULLUP_ONLY);
static InputPin CFG2(GPIO_NUM_19, GPIO_PULLUP_ONLY);

uint8_t read_hardware_config() {
  return (CFG1.is_high() ? 0 : 0x01) | (CFG2.is_high() ? 0 : 0x02);
}

}  // namespace io