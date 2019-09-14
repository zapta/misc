EESchema Schematic File Version 4
LIBS:board-cache
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
Wire Wire Line
	2900 4050 3100 4050
Wire Wire Line
	3100 4050 3100 3300
Wire Wire Line
	3100 3300 2900 3300
Wire Wire Line
	2900 3400 3200 3400
Wire Wire Line
	3200 4150 2900 4150
Wire Wire Line
	2900 3500 3300 3500
Wire Wire Line
	3300 3500 3300 4250
Wire Wire Line
	3300 4250 2900 4250
Wire Wire Line
	2900 4350 3400 4350
Wire Wire Line
	3400 4350 3400 3600
Wire Wire Line
	3400 3600 2900 3600
Wire Wire Line
	2950 2300 2950 2250
Wire Wire Line
	2950 2250 3200 2250
Wire Wire Line
	4750 2450 4850 2450
Wire Wire Line
	4850 2450 4850 2500
Wire Wire Line
	4750 2250 5000 2250
Wire Wire Line
	5300 2250 5450 2250
Wire Wire Line
	5050 3050 4900 3050
Wire Wire Line
	5350 3050 5450 3050
Connection ~ 5450 3050
Wire Wire Line
	4100 4800 3100 4800
Wire Wire Line
	4300 4800 4900 4800
$Comp
L board:Screw_Terminal_x02 J4
U 1 1 5CFA831F
P 2750 2400
F 0 "J4" H 2670 2167 50  0000 C CNN
F 1 "Screw_Terminal_x02" H 2670 2166 50  0001 C CNN
F 2 "board:Terminal-block" H 2750 2400 50  0001 C CNN
F 3 "" H 2750 2400 50  0001 C CNN
	1    2750 2400
	-1   0    0    1   
$EndComp
$Comp
L board:Resistor R2
U 1 1 5CFB0103
P 3350 2700
F 0 "R2" V 3250 2700 50  0000 C CNN
F 1 "10k" V 3150 2700 50  0000 C CNN
F 2 "board:Resistor" H 3350 2700 50  0001 C CNN
F 3 "" H 3350 2700 50  0001 C CNN
	1    3350 2700
	0    -1   -1   0   
$EndComp
$Comp
L board:Resistor R1
U 1 1 5CFB1717
P 4200 4800
F 0 "R1" V 4405 4800 50  0000 C CNN
F 1 "1k" V 4314 4800 50  0000 C CNN
F 2 "board:Resistor" H 4200 4800 50  0001 C CNN
F 3 "" H 4200 4800 50  0001 C CNN
	1    4200 4800
	0    -1   -1   0   
$EndComp
$Comp
L board:Connector_01x04_Male J1
U 1 1 5CFB2CAB
P 2700 3500
F 0 "J1" H 2700 3200 50  0000 C CNN
F 1 "Connector_01x04_Male" H 2806 3687 50  0001 C CNN
F 2 "board:Connector_4" H 2700 3500 50  0001 C CNN
F 3 "" H 2700 3500 50  0001 C CNN
	1    2700 3500
	1    0    0    1   
$EndComp
$Comp
L board:Connector_01x04_Male J2
U 1 1 5CFB3F04
P 2700 4250
F 0 "J2" H 2700 3950 50  0000 C CNN
F 1 "Connector_01x04_Male" H 2806 4437 50  0001 C CNN
F 2 "board:Connector_4" H 2700 4250 50  0001 C CNN
F 3 "" H 2700 4250 50  0001 C CNN
	1    2700 4250
	1    0    0    1   
$EndComp
$Comp
L board:GND #PWR0101
U 1 1 5CFB4415
P 4850 2500
F 0 "#PWR0101" H 4850 2250 50  0001 C CNN
F 1 "GND" H 4855 2327 50  0000 C CNN
F 2 "" H 4850 2500 50  0001 C CNN
F 3 "" H 4850 2500 50  0001 C CNN
	1    4850 2500
	1    0    0    -1  
$EndComp
$Comp
L board:GND #PWR0102
U 1 1 5CFB72B9
P 5200 4650
F 0 "#PWR0102" H 5200 4400 50  0001 C CNN
F 1 "GND" H 5205 4477 50  0000 C CNN
F 2 "" H 5200 4650 50  0001 C CNN
F 3 "" H 5200 4650 50  0001 C CNN
	1    5200 4650
	1    0    0    -1  
$EndComp
$Comp
L board:GND #PWR0103
U 1 1 5CFB74A8
P 5450 4650
F 0 "#PWR0103" H 5450 4400 50  0001 C CNN
F 1 "GND" H 5455 4477 50  0000 C CNN
F 2 "" H 5450 4650 50  0001 C CNN
F 3 "" H 5450 4650 50  0001 C CNN
	1    5450 4650
	1    0    0    -1  
$EndComp
$Comp
L board:GND #PWR0104
U 1 1 5CFB7629
P 6450 4250
F 0 "#PWR0104" H 6450 4000 50  0001 C CNN
F 1 "GND" H 6455 4077 50  0000 C CNN
F 2 "" H 6450 4250 50  0001 C CNN
F 3 "" H 6450 4250 50  0001 C CNN
	1    6450 4250
	1    0    0    -1  
$EndComp
$Comp
L board:GND #PWR0105
U 1 1 5CFB792B
P 3300 4450
F 0 "#PWR0105" H 3300 4200 50  0001 C CNN
F 1 "GND" H 3305 4277 50  0000 C CNN
F 2 "" H 3300 4450 50  0001 C CNN
F 3 "" H 3300 4450 50  0001 C CNN
	1    3300 4450
	1    0    0    -1  
$EndComp
$Comp
L board:Connector_01x03_Male J3
U 1 1 5CFB9A26
P 6750 3950
F 0 "J3" H 6800 4150 50  0000 R CNN
F 1 "Connector_01x03_Male" H 6722 3971 50  0001 R CNN
F 2 "board:Connector_3" H 6750 3950 50  0001 C CNN
F 3 "" H 6750 3950 50  0001 C CNN
	1    6750 3950
	-1   0    0    -1  
$EndComp
$Comp
L board:Isolated_DC_DC U2
U 1 1 5CFBC497
P 4350 2350
F 0 "U2" H 4300 2767 50  0000 C CNN
F 1 "TBA 2-2411" H 4300 2676 50  0000 C CNN
F 2 "board:DC-DC" H 4350 1950 50  0001 C CIN
F 3 "" H 4350 1850 50  0001 C CNN
	1    4350 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	3500 2250 3600 2250
Wire Wire Line
	2950 2400 2950 2450
Wire Wire Line
	3450 2700 3600 2700
Connection ~ 3600 2250
Wire Wire Line
	3600 2250 3850 2250
Wire Wire Line
	3600 2250 3600 2700
Wire Wire Line
	2950 2450 3100 2450
Wire Wire Line
	3250 2700 3100 2700
Wire Wire Line
	3100 2700 3100 2450
Connection ~ 3100 2450
Wire Wire Line
	3100 2450 3850 2450
Wire Wire Line
	5450 2250 5450 3050
Wire Wire Line
	4900 3050 4900 3350
Text Label 5950 3950 0    50   ~ 0
DATA
Wire Wire Line
	5900 3950 6550 3950
Text Label 3400 4800 0    50   ~ 0
SERIAL_IN
Text Notes 3850 2900 0    50   ~ 0
For 12VDC input replace
Text Notes 3850 3000 0    50   ~ 0
with TBA 2-1211.
Text Notes 7200 4050 0    50   ~ 0
To WS2812/B strip.\n5 LEDS max (60ma max per LED)
Text Notes 3500 3250 0    50   ~ 0
VERY IMPORTANT:
Text Notes 1650 4250 0    50   ~ 0
To PanelDue
Text Notes 3500 3350 0    50   ~ 0
Cut the VIN/VUSB link trace at
Text Notes 3500 3450 0    50   ~ 0
at the bottom side of the
Text Notes 3000 1800 0    50   ~ 0
Reversed voltage
Text Notes 3000 1900 0    50   ~ 0
\nprotection, 30V min
Text Notes 1650 3500 0    50   ~ 0
From Duet3D
Text Notes 1900 2350 0    50   ~ 0
From 24VDC
Text Notes 1900 2450 0    50   ~ 0
power supply
Text Notes 3250 4900 0    50   ~ 0
57600 baud 5V
Text Notes 3850 2800 0    50   ~ 0
Isolated DC/DC.\n
Text Notes 7150 6850 0    50   ~ 0
Duet3D status monitor.
$Comp
L board:Teensy-LC-Simplified U1
U 1 1 5CF9C1F4
P 5500 4750
F 0 "U1" H 4470 5603 60  0000 R CNN
F 1 "Teensy-LC" H 4470 5497 60  0000 R CNN
F 2 "board:TEENSY-LC" H 5500 4200 60  0001 C CNN
F 3 "" H 5500 4200 60  0000 C CNN
	1    5500 4750
	1    0    0    -1  
$EndComp
Wire Wire Line
	3200 3400 3200 4150
Connection ~ 3100 4050
Wire Wire Line
	3300 4250 3300 4450
Connection ~ 3300 4250
Wire Wire Line
	5450 4650 5450 4550
Wire Wire Line
	5200 4550 5200 4650
Wire Wire Line
	4900 4550 4900 4800
Wire Wire Line
	3100 4050 3100 4800
Text Notes 2600 2300 0    50   ~ 0
+
Text Notes 2600 2450 0    50   ~ 0
-
Text Notes 2350 3650 0    50   ~ 0
+5V
Text Notes 2350 3550 0    50   ~ 0
GND
Text Notes 2350 3450 0    50   ~ 0
URXD0
Text Notes 2350 3350 0    50   ~ 0
UTXD0
Text Notes 2350 4400 0    50   ~ 0
+5V
Text Notes 2350 4300 0    50   ~ 0
GND
Text Notes 2350 4200 0    50   ~ 0
URXD0
Text Notes 2350 4100 0    50   ~ 0
UTXD0
Text Notes 6850 3900 0    50   ~ 0
GND
Text Notes 6850 4000 0    50   ~ 0
DATA
Text Notes 6850 4100 0    50   ~ 0
+5V
Text Notes 2100 4700 0    50   ~ 0
2 x 2.54mm KF2510 \n4pin male connectors
Text Notes 6850 4350 0    50   ~ 0
2.54mm KF2510 \n3pin male connector
Text Notes 2250 2650 0    50   ~ 0
0.2” terminal block
$Comp
L Diode:1N5817 D1
U 1 1 5CFC7588
P 3350 2250
F 0 "D1" H 3350 2034 50  0000 C CNN
F 1 "1N5819" H 3350 2125 50  0000 C CNN
F 2 "board:Diode" H 3350 2075 50  0001 C CNN
F 3 "http://www.vishay.com/docs/88525/1n5817.pdf" H 3350 2250 50  0001 C CNN
	1    3350 2250
	-1   0    0    1   
$EndComp
$Comp
L Diode:1N5817 D2
U 1 1 5CFC9B1F
P 5150 2250
F 0 "D2" H 5150 2034 50  0000 C CNN
F 1 "1N5817" H 5150 2125 50  0000 C CNN
F 2 "board:Diode" H 5150 2075 50  0001 C CNN
F 3 "http://www.vishay.com/docs/88525/1n5817.pdf" H 5150 2250 50  0001 C CNN
	1    5150 2250
	-1   0    0    1   
$EndComp
$Comp
L Diode:1N5817 D3
U 1 1 5CFC9CFA
P 5200 3050
F 0 "D3" H 5200 2834 50  0000 C CNN
F 1 "1N5817" H 5200 2925 50  0000 C CNN
F 2 "board:Diode" H 5200 2875 50  0001 C CNN
F 3 "http://www.vishay.com/docs/88525/1n5817.pdf" H 5200 3050 50  0001 C CNN
	1    5200 3050
	-1   0    0    1   
$EndComp
$Comp
L Mechanical:MountingHole H4
U 1 1 5CFC0EB1
P 2450 7050
F 0 "H4" H 2550 7096 50  0000 L CNN
F 1 "MountingHole" H 2550 7005 50  0000 L CNN
F 2 "board:Mounting-hole" H 2450 7050 50  0001 C CNN
F 3 "~" H 2450 7050 50  0001 C CNN
	1    2450 7050
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H1
U 1 1 5CFC32A2
P 2450 6700
F 0 "H1" H 2550 6746 50  0000 L CNN
F 1 "MountingHole" H 2550 6655 50  0000 L CNN
F 2 "board:Mounting-hole" H 2450 6700 50  0001 C CNN
F 3 "~" H 2450 6700 50  0001 C CNN
	1    2450 6700
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H2
U 1 1 5CFC34FD
P 3100 6700
F 0 "H2" H 3200 6746 50  0000 L CNN
F 1 "MountingHole" H 3200 6655 50  0000 L CNN
F 2 "board:Mounting-hole" H 3100 6700 50  0001 C CNN
F 3 "~" H 3100 6700 50  0001 C CNN
	1    3100 6700
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H3
U 1 1 5CFC385E
P 3100 7050
F 0 "H3" H 3200 7096 50  0000 L CNN
F 1 "MountingHole" H 3200 7005 50  0000 L CNN
F 2 "board:Mounting-hole" H 3100 7050 50  0001 C CNN
F 3 "~" H 3100 7050 50  0001 C CNN
	1    3100 7050
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 3050 5450 3200
Wire Wire Line
	6550 4050 6300 4050
Wire Wire Line
	6300 4050 6300 3200
Wire Wire Line
	6300 3200 5450 3200
Connection ~ 5450 3200
Wire Wire Line
	5450 3200 5450 3350
Wire Wire Line
	6550 3850 6450 3850
Wire Wire Line
	6450 3850 6450 4250
Text Notes 5600 2600 0    50   ~ 0
5V power OR.
Text Notes 5600 2700 0    50   ~ 0
Low forward voltage Schottky
Text Notes 4000 4950 0    50   ~ 0
Input protection
Wire Bus Line
	4800 3700 4500 3450
Text Notes 3500 3550 0    50   ~ 0
Teensy LC.
$EndSCHEMATC
