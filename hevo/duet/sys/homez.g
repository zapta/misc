; homez.g
;
; called to home the Z axis

;M117 Started Home Z

G91               ; relative positioning
G1 Z5 F6000 S2    ; lift Z relative to current position

G90               ; absolute positioning
G1 X5 Y29 F6000   ; go to probing point (close to edge, for better support if bltouch fails)
M558 A1 F800      ; Set for probing at fast speed
G30               ; Probe and home Z
M558 A5 F100	  ; Set for probing at slow speed, allow multiple trys
G30               ; Probe and home Z

M98 P"/macros/park_up"

;M117 Ended Home Z

