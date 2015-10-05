#!/bin/bash
#
# A command line script to program a Paste Injector board via the ICSP connector.
# Requires an installed avrdude software and having a working programmer.

# See avrdude command line options here http://www.nongnu.org/avrdude/user-manual/avrdude.html

# Set this to the code of the programmer you have. See above link for programmer codes.
#
PROGRAMMER_CODE="avrispmkII"

# NOTE: add multiple '-v' flags to increase verbosity.

STD_ARGS="
  -B 4  \
  -c ${PROGRAMMER_CODE} \
  -p m328p \
  "

# Assert that the last command terminated with OK status
function check_last_cmd() {
  status=$?
  if [ "$status" -ne "0" ]; then
    echo "$1 failed (status: $status)"
    echo "ABORTED"
    exit 1
  fi
  echo "$1 was ok"
}

avrdude \
  ${STD_ARGS} \
  -u \
  -U lfuse:w:0xff:m
check_last_cmd "Programming L fuses"

avrdude \
  ${STD_ARGS} \
  -u \
  -U hfuse:w:0xda:m
check_last_cmd "Programming H fuses"

avrdude \
  ${STD_ARGS} \
  -u \
  -U efuse:w:0x05:m
check_last_cmd "Programming E fuses"

avrdude \
  ${STD_ARGS} \
  -U flash:w:paste_injector.hex:i
check_last_cmd "Programming flash"

echo "ALL DONE OK"

