; homeall.g
;
; called to home all axes

G91               ; relative positioning
G1 Z5 F6000 S2    ; lift Z relative to current position

; Home X
M913 X50          ; X motors to 50% current
G1 S1 X-320 F3600 ; move until motors hit X min and stall
G1 X10 F6000      ; go back a few mm on X
M913 X100         ; X motors to 100% current

; Home Y
M913 Y50          ; Y motors to 50% current
G1 S1 Y-320 F3600 ; move until motors hit Y min and stall
G1 Y10 F6000      ; go back a few mm on Y
M913 Y100 	  ; Y motors to 100% current

; Home Z
G90               ; absolute positioning
G1 X26 Y29 F6000  ; go to probing point (first leveling screw)
M558 A1 F800      ; Set for probing at fast speed
G30               ; Probe and home Z
M558 A5 F100	  ; Set for probing at slow speed, allow multiple trys
G30               ; Probe and home Z

M98 P"/macros/park_up"

