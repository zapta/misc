; bed.g
; called to perform automatic bed compensation via G32

M557 X32:289 Y29:285 S64                     ; Define mesh grid

G28                 ; home to be in a known state (.e.g. nozzle away from bed)
M190 S60            ; heat bed and wait until ready
G28                 ; home again with a hot bed

M561                ; clear any bed transform
;M98 Pdeployprobe.g  ; deploy mechanical Z probe
; NOTE: the probing parameters and speed are from the M558 command in config.g
;       some M558 params may be modified in homeall.g
G29                 ; probe the bed and enable compensation
;98 Pretractprobe.g ; retract mechanical Z probe

M140 S0             ; bed temp = 0
M140 S-273.15       ; turn bed off

M98 P"/macros/park_up"
