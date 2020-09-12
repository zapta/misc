// Board: arduino nano every
// Register emulation: none.

#include "io.h"
#include "programs.h"

// Initialized in setup.
static int program_num;
static programs::Program* program = nullptr;

void setup() {
  Serial.begin(115200);
  io::printf("\nPulser program started.\n");
  //pinMode(LED0, OUTPUT);
  //io::setup();

  program_num = io::rotary_read();
  io::printf("Progam selector = %d\n", program_num);

  switch (program_num) {
    case 0:
      program = new programs::Program0;
      break;
    case 1:
      program = new programs::Program1;
      break;
    default:
      for (;;) {
        io::printf("\nUnknown program %d\n", program_num);
        delay(200);
        io::LED0.toggle();
        //digitalWrite(LED0, !digitalRead(LED0));
      }
  }

  io::printf("Goign to setup program %d\n", program_num);
  delay(200);
  program->setup();
  io::printf("Program setup() done\n");
}


void loop() {

   // program->loop();
  //io::LED0.toggle();
  io::LED0.set(io::REMOTE_SWITCH.is_on());
  io::printf("\nAnalog: %d\n\n", io::CURRENT_SENSE.read());
  io::printf("\nRotary: %d\n\n", io::rotary_read());

  delay(100);

  //io::dump_adc0_registers();

}
