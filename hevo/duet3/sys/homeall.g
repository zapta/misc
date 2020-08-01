; homeall.g

G29 S2            ; disable bed mesh compensation

; Drop bed a little, for head clearance.
G91               ; relative positioning
M400
M913 Z20          ; Z motors to 20% current
G1 Z5 F1000  H2   ; drop bed Z relative to current position
M400
M913 Z100         ; Z motors to 100% current
M280 P3 S160 I1   ; Reset bltouch in case it didn't have vertical clearance for self test.
G90               ; abs positioning

; Home X
G91               ; relative positioning
M400
M913 X35 Y35      ; XY motors to 35% current
G1 H1 X-310 F2000 ; move until motors hit X min and stall
G1 X10 F3000      ; go back a few mm on X
M400
M913 X100 Y100    ; XY motors to 100% current
G90               ; abs positioning

; Home Y
G91               ; relative positioning
M400
M913 X35 Y35      ; XY motors to 35% current
G1 H1 Y-320 F2000 ; move until motors hit Y min and stall
G1 Y10 F3000      ; go back a few mm on Y
M400
M913 X100 Y100    ; XY motors to 100% current
G90               ; abs positioning

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
G1 Z30 F600      ; move bed down

