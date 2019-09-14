#!/bin/bash

curl  -v http://10.0.0.9/rr_filelist?dir=0:/gcodes | python -mjson.tool
