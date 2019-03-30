; homex.g
;
; called to home the X axis

G91               ; relative positioning
G1 Z5 F6000 S2    ; lift Z relative to current position

M913 X50          ; X motors to 50% current
G1 S1 X-320 F3600 ; move until motors hit X min and stall
G1 X10 F6000      ; go back a few mm on X
M913 X100         ; X motors to 100% current

G90               ; absolute positioning
M98 P"/macros/park_up"

