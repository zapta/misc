; pause.g
; called when a print from SD card is paused
;
M83               ; relative extruder moves
G1 E-3 F3600      ; retract 3mm of filament

G91               ; relative positioning
G1 Z20 F800       ; lift Z by 20

G90               ; absolute positioning
G1 X0 Y200 F6000  ; go to X=0 Y=200

