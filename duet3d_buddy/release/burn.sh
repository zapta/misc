#!/usr/bin/bash -x

# This file is a work in progress....

port="COM3"

# Go to home directory
#cd 
#rel="/c/projects/misc/repo/duet3d_buddy/release"
#builddir="AppData/Local/Temp/arduino_build_444145"
#esp32dir="AppData/Local/Arduino15/packages/esp32"
#esptool="${esp32dir}/tools/esptool_py/2.6.1/esptool.exe"
#esptool="${rel}/esptool.exe"
#  0xe000  ${esp32dir}/hardware/esp32/1.0.4/tools/partitions/boot_app0.bin \
#  0x1000  ${esp32dir}/hardware/esp32/1.0.4/tools/sdk/bin/bootloader_qio_80m.bin \
#  0x10000 ${builddir}/arduino.ino.bin \
#  0x8000  ${builddir}/arduino.ino.partitions.bin
#${esptool} \

./esptool.exe \
  --chip esp32 \
  --port ${port} \
  --baud 921600  \
  --before default_reset \
  --after hard_reset \
  write_flash \
  -z  \
  --flash_mode dio \
  --flash_freq 80m \
  --flash_size detect \
  0xe000  ./boot_app0.bin \
  0x1000  ./bootloader_qio_80m.bin \
  0x10000 ./arduino.ino.bin \
  0x8000  ./arduino.ino.partitions.bin


