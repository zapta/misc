
#include "programs.h"
#include "io.h"

namespace programs {

void Program0::setup() {

}


static void test(io::DigitalOutPin& led) {
    led.toggle();
    io::printf("Value: %d\n", led.is_on());
    delay(1000);
    led.toggle();

    io::printf("Value: %d\n", led.is_on());

    delay(1000);
}

void Program0::loop() {
  test(io::LED2);
}

} // namespace programs
