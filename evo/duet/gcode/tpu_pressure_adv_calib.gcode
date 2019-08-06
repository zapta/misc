; From https://pastebin.com/1jD64HgH
; Per https://forum.duet3d.com/topic/8467/pressure-advance-calibration/2
;
; K-Factor Test
;
; Created: Fri Dec 08 2017 18:11:17 GMT-0800 (Pacific Standard Time)
; Settings:
; Filament Diameter = 1.75
; Nozzle Diameter = 0.4
; Nozzle Temperature = 220
; Nozzle / Line Ratio = 1.1
; Bed Temperature = 60
; Slow Printing Speed = 1200  // mm/min
; Fast Printing Speed = 4200  // mm/min
; Movement Speed = 12000
; Use UBL = false
; Retraction Distance = 2.5
; Bed Size X = 300
; Bed Size Y = 300
; Layer Height = 0.2
; Extrusion Multiplier = 1
; Starting Value K-Factor = 0
; Ending value K-Factor = 100
; K-Factor Stepping = 5
;

T0
M140 S60 ; set and wait for bed temp
M104 S220 ; set nozzle temp and continue
M109 S220 ; block waiting for nozzle temp
M190 S60

G28 ; home all

M204 S500 ; lower acceleration to 500mm/s2 during the test
G90 ; use absolute coordinates
M83 ; use relative distances for extrusion


; go to layer height and prime nozzle on a line to the left
;
G1 X90 Y87.5 F12000
G1 Z0.2 F1200
G1 X90 Y187.5 E10 F600 ; extrude some to start clean
G1 E-2.5

;
; start the test (all values are relative coordinates)
;
G1 X110 Y87.5 F12000 ; move to pattern start
G91 ; use relative coordinates

; line 1
M572 D0 S0.0 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 2
M572 D0 S0.1 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 3
M572 D0 S0.2 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 4
M572 D0 S0.3 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 5
M572 D0 S0.4 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 6
M572 D0 S0.5 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 7
M572 D0 S0.6 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 8
M572 D0 S0.7 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 9
M572 D0 S0.8 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 10
M572 D0 S0.9 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 11
M572 D0 S1.0 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 12
M572 D0 S1.1 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 13
M572 D0 S1.2 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 14
M572 D0 S1.3 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

; line 15
M572 D0 S1.4 ; set K-factor
M400
G1 E2.5
G1 X20 Y0 E0.73172 F600
G1 X40 Y0 E1.46345 F1200
G1 X20 Y0 E0.73172 F600
G1 E-2.5
G1 X-80 Y5 F12000

;
; mark the test area for reference
;
M572 D0 S0.0 ; set K-factor
M400
G1 X20 Y0 F12000
G1 E2.5
G1 X0 Y20 E0.73172 F600
G1 E-2.5
G1 X40 Y-20 F12000
G1 E2.5
G1 X0 Y20 E0.73172 F600
G1 E-2.5
;
; finish
;
M400
G90 ; use absolute coordinates
G1 Z30 Y200 F12000 ; move away from the print

