; homey.g
; called to home the Y axis

; Home Y
G91               ; relative positioning
M400
M913 X35 Y35      ; XY motors to 35% current
G1 H1 Y-320 F4000 ; move until motors hit Y min and stall
G1 Y10 F3000      ; go back a few mm on Y
M400
M913 X100 Y100    ; XY motors to 100% current
G90               ; abs positioning

