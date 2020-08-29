#!/bin/bash

log="/tmp/automesh.txt"
python3="/Library/Frameworks/Python.framework/Versions/3.6/bin/python3"

date > $log
echo "Args: $*" >> $log
echo >> $log

$python3 /projects/misc/repo/duet3d_automesh/duet3d_automesh.py "$*" 2>&1 > $log

RESULT=$?
if [ $RESULT -eq 0 ]; then
  osascript -e 'display notification "OK." with title "Duet automesh"'
else
  osascript -e 'display notification "Failed." with title "Duet automesh"'
fi



