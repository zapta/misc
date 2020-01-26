; Before running, home manually x,y

;M906 X1500 Y1500 Z1500 E1200 I30              ; Set motor currents (mA) and motor idle factor in per cent
M906 X1500 Y1500               ; Set motor currents (mA) and motor idle factor in per cent
;M906 X2000 Y2000               ; Set motor currents (mA) and motor idle factor in per cent
;M906 X1000 Y1000               ; Set motor currents (mA) and motor idle factor in per cent

;G28 XY  ;home xy

G1 X100 Y100 F4000 ; lower left
G1 X200 Y200 F4000 ; upper right 
G1 X100 Y100 F4000 ; lower left
G1 X200 Y200 F4000 ; upper right 
G1 X100 Y100 F4000 ; lower left
G1 X200 Y200 F4000 ; upper right 
G1 X100 Y100 F4000 ; lower left
G1 X200 Y200 F4000 ; upper right 

G1 X200 Y100 F4000 ; lower right 
G1 X100 Y200 F4000 ; upper left
G1 X200 Y100 F4000 ; lower right 
G1 X100 Y200 F4000 ; upper left
G1 X200 Y100 F4000 ; lower right 
G1 X200 Y100 F4000 ; lower right 
G1 X100 Y200 F4000 ; upper left
G1 X100 Y200 F4000 ; upper left


;G1 X150 Y200 F6100 ; upper right
;G1 X150 Y100 F6100 ; upper right
;G1 X150 Y200 F6100 ; upper right
;G1 X150 Y100 F6100 ; upper right
;G1 X150 Y200 F6100 ; upper right
;G1 X150 Y100 F6100 ; upper right
;G1 X150 Y200 F6100 ; upper right
;G1 X150 Y100 F6100 ; upper right

;G1 Y150 X200 F6100 ; upper right
;G1 Y150 X100 F6100 ; upper right
;G1 Y150 X200 F6100 ; upper right
;G1 Y150 X100 F6100 ; upper right
;G1 Y150 X200 F6100 ; upper right
;G1 Y150 X100 F6100 ; upper right
;G1 Y150 X200 F6100 ; upper right
;G1 Y150 X100 F6100 ; upper right




