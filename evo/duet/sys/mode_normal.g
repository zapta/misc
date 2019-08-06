; Stanard configuration. Called after modifying them for stall detection.

;M117 mode_normal.g called

;TODO: add P1 argument to M566 to support latest policy

;M566 X3000 Y3000 Z200 E3000    ; Set maximum instantaneous speed changes (mm/min) (Jerk)
;M566 X1500 Y1500 Z200 E3000    ; Set maximum instantaneous speed changes (mm/min) (Jerk)
;M566 X1200 Y1200 Z100 E3000    ; Set maximum instantaneous speed changes (mm/min) (Jerk)
M566 X600 Y600 Z100 E3000       ; Set maximum instantaneous speed changes (mm/min) (Jerk)


;M201 X6000 Y6000 Z30  E8000    ; Set maximum accelerations (mm/s^2)
;M201 X1200 Y1200 Z30  E8000     ; Set maximum accelerations (mm/s^2)
M201 X600 Y600 Z30  E8000      ; Set maximum accelerations (mm/s^2)

