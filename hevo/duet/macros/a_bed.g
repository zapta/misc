; bed.g
; called to perform automatic bed compensation via G32

M561                ; clear any bed transform

G28                 ; home to be in a known state (.e.g. nozzle away from bed)
;@@@ restore this
;M190 S60            ; heat bed and wait until ready
;G28                 ; home again with a hot bed


M671 X-38:172 Y-38:172 S1.0 ; leadscrews at left (connected to Z) and right (connected to E1) of X axis

;M98 Pdeployprobe.g  ; deploy mechanical Z probe
; NOTE: the probing parameters and speed are from the M558 command in config.g
;       some M558 params may be modified in homeall.g
;G29                 ; probe the bed and enable compensation

G30 P0 X30 Y172 Z-99999 ; probe near a leadscrew, half way along Y axis
G30 P1 X280 Y172 Z-99999 S2 ; probe near a leadscrew and calibrate 2 motors

M140 S0             ; bed temp = 0
M140 S-273.15       ; turn bed off

M98 P"/macros/park_up"
