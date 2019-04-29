; homey.g
;
; called to home the Y axis
;

G91               ; relative positioning
G1 Z5 F6000 S2    ; lift Z relative to current position

M913 X50 Y50      ; XY motors to 50% current
G1 S1 Y-320 F3600 ; move until motors hit Y min and stall
G1 Y10 F6000      ; go back a few mm on Y
M913 X100 Y100 	  ; XY motors to 100% current

G1 Z-5 F6000 S2   ; lower Z back, relative
G90               ; absolute positioning
;M98 P"/macros/park_up"
