// Board: arduino nano every
// Register emulation: none.

#include "io.h"
#include "programs.h"

constexpr int LED0 = 13;

// Initialized in setup.
static int program_num;
static Program* program = nullptr;

void setup() {
  Serial.begin(115200);
  io::printf("\nPulser program started.\n");
  pinMode(LED0, OUTPUT);
  io::setup();

  program_num = io::rotary_read();
  io::printf("Progam selector = %d\n", program_num);

  switch (program_num) {
    case 0:
      program = new Program_0;
      break;
    case 1:
      program = new Program_1;
      break;
    default:
      for (;;) {
        io::printf("\nUnknown program %d\n", program_num);
        delay(200);
        digitalWrite(LED0, !digitalRead(LED0));
      }
  }

  io::printf("Goign to setup program %d\n", program_num);
  delay(200);
  program->setup();
  io::printf("Program setup() done\n");
}

void loop() {
  program->loop();
  //  counter++;
  //  io::printf("\nLoop %d: rotary=%d\n", counter, io::rotary_read());
  //  digitalWrite(LED0, counter & 0x1);
  //  delay(1000);
}
