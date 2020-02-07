; Stanard configuration. Called after modifying them for stall detection.

;TODO: add P1 argument to M566 to support latest policy

M566 X300  Y300  Z100 E3000    ; Set maximum instantaneous speed changes (mm/min) (Jerk)
M201 X600  Y600 Z60  E9000     ; Set maximum accelerations (mm/s^2)










