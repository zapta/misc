#!/bin/bash -x

rm -f Calib100mm-right.x3g

/Applications/Simplify3D-4.0.0/gpx  -p -m r1d Calib100mm-right.gcode

../simplify3d/start_flashair_uploader.sh Calib100mm-right.x3g


