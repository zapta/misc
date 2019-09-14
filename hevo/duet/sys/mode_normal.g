; Stanard configuration. Called after modifying them for stall detection.

;M117 mode_normal.g called

;TODO: add P1 argument to M566 to support latest policy

M566 X600  Y600  Z100 E3000    ; Set maximum instantaneous speed changes (mm/min) (Jerk)
M201 X300  Y300 Z60  E9000     ; Set maximum accelerations (mm/s^2)



