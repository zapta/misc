REM * A batch file to upload the Duet Buddy firmware to a M5Stack Core.
REM * This script requires a Silicon Labs serial driver to communicate
REM * with the M5Stack core. If your computer doesn't have that driver,
REM * You can download it from https://m5stack.com/pages/download or
REM * directly from Silabs.com.

REM * Set this to the name of the virtual serial port of your computer
REM * that is connected to the M5Stack Core (via USb cable).
set port=COM3

REM * The burning is done using espressif's ESP32 tool. A binary
REM * is provided here or you can download it directly.
REM * That binary was copied from an Arduino/ESP32/M5Stack
REM * installation.
REM *
REM * This command mimics the operation that the Arduino IDE
REM * does to download the firmware to the M5Stack and the .bin
REM * files were copied from the Arduino IDE to the common directory
REM * here.
.\esptool.exe ^
  --chip esp32 ^
  --port %port% ^
  --baud 921600  ^
  --before default_reset ^
  --after hard_reset ^
  write_flash ^
  -z  ^
  --flash_mode dio ^
  --flash_freq 80m ^
  --flash_size detect ^
  0xe000  ..\common\boot_app0.bin ^
  0x1000  ..\common\bootloader_qio_80m.bin ^
  0x10000 ..\common\arduino.ino.bin ^
  0x8000  ..\common\arduino.ino.partitions.bin


