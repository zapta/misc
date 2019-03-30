; bed.g
; called to perform automatic bed compensation via G32

G28                 ; home to be in a known state
M190 S60            ; heat bed and wait until ready
G28                 ; home again with a hot bed

M561                ; clear any bed transform
M98 Pdeployprobe.g  ; deploy mechanical Z probe
G29                 ; probe the bed and enable compensation
M98 Pretractprobe.g ; retract mechanical Z probe

M140 S0             ; bed temp = 0
M140 S-273.15       ; turn bed off

M98 P"/macros/park_up"
