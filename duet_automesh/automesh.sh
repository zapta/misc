#!/bin/bash

log="/tmp/automesh.txt"
python3="/Library/Frameworks/Python.framework/Versions/3.6/bin/python3"

date > $log
echo "Args: $*" >> $log
echo >> $log

$python3 /projects/misc/repo/duet_automesh/duet_automesh.py $* 2>&1 | tee -a $log


