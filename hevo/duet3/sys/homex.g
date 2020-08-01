; homex.g
; called to home the X axis

; Home X
G91               ; relative positioning
M400
M913 X35 Y35      ; XY motors to 35% current
G1 H1 X-310 F2000 ; move until motors hit X min and stall
G1 X10 F3000      ; go back a few mm on X
M400
M913 X100 Y100    ; XY motors to 100% current
G90               ; abs positioning

