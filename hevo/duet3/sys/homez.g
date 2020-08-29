; homez.g
; called to home the Z axis

; Home Z
M400
G90               ; absolute positioning
G1 X120 Y172 F6000   ; go to probing point (between two Z rods, 30mm bltouch offset)
M400
M913 Z60          ; Z motors to 60% current, in case something goes wrong with bltouch
M558 A1 F800      ; Set for probing at fast speed, single probe
G30               ; Probe and home Z (pass 1)
M400
M913 Z100         ; Z motors to 100% current
M558 A5 F100      ; Set for probing at slow speed, allow multiple trys
G30               ; Probe and home Z
G1 Z30 F600       ; move bed down

