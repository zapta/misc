#!/bin/bash -x
#
# A command line script to read the flash of a Paste Injector board via the ICSP connector.
# Requires an installed avrdude software and having a working programmer.

# See avrdude command line options here http://www.nongnu.org/avrdude/user-manual/avrdude.html

# Set this to the code of the programmer you have. See above link for programmer codes.
PROGRAMMER_CODE="avrispmkII"

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
  -B 4 \
  -c ${PROGRAMMER_CODE} \
  -p m328p \
  -v -v -v \
  -U flash:r:_paste_injector.hex:i
check_last_cmd "Reading flash"

echo "All Done OK"

