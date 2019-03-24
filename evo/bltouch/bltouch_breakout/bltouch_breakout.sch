EESchema Schematic File Version 4
LIBS:bltouch_breakout-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector_Generic:Conn_02x25_Odd_Even J1
U 1 1 5C913016
P 5400 2400
F 0 "J1" V 5404 1113 50  0000 R CNN
F 1 "Conn_02x25_Odd_Even" V 5495 1113 50  0001 R CNN
F 2 "bltouch_breakout:2x25x2.54mm_Straight" H 5400 2400 50  0001 C CNN
F 3 "~" H 5400 2400 50  0001 C CNN
	1    5400 2400
	0    1    1    0   
$EndComp
Wire Wire Line
	6600 2150 6600 2200
Wire Wire Line
	6600 2150 6750 2150
Wire Wire Line
	6750 2150 6750 3150
$Comp
L Connector_Generic:Conn_01x03 J2
U 1 1 5C96F6A7
P 6500 3500
F 0 "J2" V 6419 3312 50  0000 R CNN
F 1 "Conn_01x03" V 6464 3312 50  0001 R CNN
F 2 "bltouch_breakout:Conn_1x3x2.54" H 6500 3500 50  0001 C CNN
F 3 "~" H 6500 3500 50  0001 C CNN
	1    6500 3500
	0    1    1    0   
$EndComp
Wire Wire Line
	6300 2700 6300 3150
Wire Wire Line
	6300 3150 6400 3150
Wire Wire Line
	6500 3150 6750 3150
Text Label 6550 3850 1    50   ~ 0
+5V
Text Label 6650 3850 1    50   ~ 0
GND
Text Label 6450 3850 1    50   ~ 0
SERVO
Text Notes 7200 6950 0    150  ~ 0
BLTouch Breakout for Duet2
Wire Wire Line
	6600 2700 6600 3300
Wire Wire Line
	6500 3150 6500 3300
Wire Wire Line
	6400 3150 6400 3300
$EndSCHEMATC
