; Common config settings. Refactored from config.g to a 
; macro file so we can restore it after modifiying during homing.

;M117 mode_stall.g called

;M98 P"/sys/mode_normal.g"

;M566 X600 Y600 Z100 E600      ; Set maximum instantaneous speed changes (mm/min) (Jerk)
M566 X600 Y600 Z100 E3000      ; Set maximum instantaneous speed changes (mm/min) (Jerk)
M201 X600 Y600 Z30 E600        ; Set maximum accelerations (mm/s^2)