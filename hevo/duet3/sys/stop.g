; stop.g
; called when M0 (Stop) is run (e.g. when a print from SD card is cancelled)
;

;G91                 ; relative positioning
;G1 Z300 F6000       ; lift Z relative to current position
;G90                 ; absolute positioning

M98 P"/macros/after_print"


