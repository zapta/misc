EESchema Schematic File Version 4
LIBS:stepper_analyzer-cache
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 1 1
Title "Stepper Motor Analyzer"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	4150 2050 4250 2050
Wire Wire Line
	3850 2050 3850 2200
Connection ~ 3850 2050
Wire Wire Line
	3950 2050 3850 2050
$Comp
L Device:C_Small C2
U 1 1 5D6DDD3E
P 4050 2050
F 0 "C2" V 3821 2050 50  0000 C CNN
F 1 "0.1uF" V 3912 2050 50  0000 C CNN
F 2 "stepper_analyzer:C_0603_1608Metric" H 4050 2050 50  0001 C CNN
F 3 "~" H 4050 2050 50  0001 C CNN
	1    4050 2050
	0    1    1    0   
$EndComp
Wire Wire Line
	3800 3100 3900 3100
Connection ~ 3800 3100
Wire Wire Line
	3800 3000 3800 3100
Wire Wire Line
	3900 3100 4000 3100
Connection ~ 3900 3100
Wire Wire Line
	3900 3000 3900 3100
Wire Wire Line
	4000 3100 4100 3100
Connection ~ 4000 3100
Wire Wire Line
	4000 3000 4000 3100
Wire Wire Line
	4100 3100 4100 3000
Wire Wire Line
	3700 3100 3800 3100
Wire Wire Line
	3700 3000 3700 3100
Wire Wire Line
	3850 1900 3850 2050
Wire Wire Line
	2950 3350 3050 3350
Wire Wire Line
	2750 3350 2650 3350
$Comp
L Device:C_Small C1
U 1 1 5DA1F995
P 2850 3350
F 0 "C1" V 2621 3350 50  0000 C CNN
F 1 "0.1uF" V 2712 3350 50  0000 C CNN
F 2 "stepper_analyzer:C_0603_1608Metric" H 2850 3350 50  0001 C CNN
F 3 "~" H 2850 3350 50  0001 C CNN
	1    2850 3350
	0    1    1    0   
$EndComp
Wire Wire Line
	2650 3200 2650 3350
$Comp
L Device:R_Small_US R5
U 1 1 5DA23C63
P 5550 3100
F 0 "R5" V 5345 3100 50  0000 C CNN
F 1 "330R" V 5436 3100 50  0000 C CNN
F 2 "stepper_analyzer:R_0603_1608Metric" H 5550 3100 50  0001 C CNN
F 3 "~" H 5550 3100 50  0001 C CNN
	1    5550 3100
	0    1    1    0   
$EndComp
$Comp
L Connector_Generic:Conn_01x04 J2
U 1 1 5DA27E7D
P 2400 1600
F 0 "J2" V 2450 1250 50  0000 C CNN
F 1 "Conn_01x04" H 2318 1826 50  0001 C CNN
F 2 "stepper_analyzer:Molex_KK-254_AE-6410-04A_1x04_P2.54mm_Vertical" H 2400 1600 50  0001 C CNN
F 3 "~" H 2400 1600 50  0001 C CNN
	1    2400 1600
	0    -1   -1   0   
$EndComp
$Comp
L Connector_Generic:Conn_01x04 J1
U 1 1 5DA29873
P 1500 1600
F 0 "J1" V 1550 1250 50  0000 C CNN
F 1 "Conn_01x04" H 1418 1826 50  0001 C CNN
F 2 "stepper_analyzer:Molex_KK-254_AE-6410-04A_1x04_P2.54mm_Vertical" H 1500 1600 50  0001 C CNN
F 3 "~" H 1500 1600 50  0001 C CNN
	1    1500 1600
	0    -1   -1   0   
$EndComp
$Comp
L Device:C_Small C5
U 1 1 5DA16E17
P 8500 4300
F 0 "C5" V 8300 4100 50  0000 C CNN
F 1 "0.1uF" V 8400 4150 50  0000 C CNN
F 2 "stepper_analyzer:C_0603_1608Metric" H 8500 4300 50  0001 C CNN
F 3 "~" H 8500 4300 50  0001 C CNN
	1    8500 4300
	0    1    1    0   
$EndComp
$Comp
L stepper_analyzer:LED D1
U 1 1 5DA1EAF1
P 3475 6950
F 0 "D1" V 3575 6850 50  0000 R CNN
F 1 "LED" V 3475 6850 50  0000 R CNN
F 2 "stepper_analyzer:LED_0603_1608Metric" H 3475 6950 50  0001 C CNN
F 3 "~" H 3475 6950 50  0001 C CNN
	1    3475 6950
	0    -1   -1   0   
$EndComp
$Comp
L stepper_analyzer:LED D2
U 1 1 5DA1F8F0
P 3875 6950
F 0 "D2" V 3975 6850 50  0000 R CNN
F 1 "LED" V 3875 6850 50  0000 R CNN
F 2 "stepper_analyzer:LED_0603_1608Metric" H 3875 6950 50  0001 C CNN
F 3 "~" H 3875 6950 50  0001 C CNN
	1    3875 6950
	0    -1   -1   0   
$EndComp
$Comp
L stepper_analyzer:LED D3
U 1 1 5DA2009A
P 4275 6950
F 0 "D3" V 4375 6850 50  0000 R CNN
F 1 "LED" V 4275 6850 50  0000 R CNN
F 2 "stepper_analyzer:LED_0603_1608Metric" H 4275 6950 50  0001 C CNN
F 3 "~" H 4275 6950 50  0001 C CNN
	1    4275 6950
	0    -1   -1   0   
$EndComp
$Comp
L stepper_analyzer:Jumper_3_Bridged12 JP2
U 1 1 5DA3E2DE
P 4700 2500
F 0 "JP2" H 4700 2600 50  0000 C CNN
F 1 "Jumper_3_Bridged12" H 4700 2613 50  0001 C CNN
F 2 "stepper_analyzer:PinHeader_1x03_P2.54mm_Vertical" H 4700 2500 50  0001 C CNN
F 3 "~" H 4700 2500 50  0001 C CNN
	1    4700 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	6800 5200 6800 5250
$Comp
L Device:R_Small_US R1
U 1 1 5DA26AF3
P 3475 6650
F 0 "R1" H 3375 6700 50  0000 C CNN
F 1 "3K" H 3375 6600 50  0000 C CNN
F 2 "stepper_analyzer:R_0603_1608Metric" H 3475 6650 50  0001 C CNN
F 3 "~" H 3475 6650 50  0001 C CNN
	1    3475 6650
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small_US R2
U 1 1 5DA27BEB
P 3875 6650
F 0 "R2" H 3775 6700 50  0000 C CNN
F 1 "3K" H 3775 6600 50  0000 C CNN
F 2 "stepper_analyzer:R_0603_1608Metric" H 3875 6650 50  0001 C CNN
F 3 "~" H 3875 6650 50  0001 C CNN
	1    3875 6650
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small_US R3
U 1 1 5DA284F9
P 4275 6650
F 0 "R3" H 4175 6700 50  0000 C CNN
F 1 "3K" H 4175 6600 50  0000 C CNN
F 2 "stepper_analyzer:R_0603_1608Metric" H 4275 6650 50  0001 C CNN
F 3 "~" H 4275 6650 50  0001 C CNN
	1    4275 6650
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR08
U 1 1 5DA2951D
P 3475 7150
F 0 "#PWR08" H 3475 6900 50  0001 C CNN
F 1 "GND" H 3479 6995 50  0000 C CNN
F 2 "" H 3475 7150 50  0001 C CNN
F 3 "" H 3475 7150 50  0001 C CNN
	1    3475 7150
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR011
U 1 1 5DA29ADC
P 3875 7150
F 0 "#PWR011" H 3875 6900 50  0001 C CNN
F 1 "GND" H 3879 6995 50  0000 C CNN
F 2 "" H 3875 7150 50  0001 C CNN
F 3 "" H 3875 7150 50  0001 C CNN
	1    3875 7150
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR013
U 1 1 5DA29E0E
P 4275 7150
F 0 "#PWR013" H 4275 6900 50  0001 C CNN
F 1 "GND" H 4279 6995 50  0000 C CNN
F 2 "" H 4275 7150 50  0001 C CNN
F 3 "" H 4275 7150 50  0001 C CNN
	1    4275 7150
	1    0    0    -1  
$EndComp
Wire Wire Line
	3475 6750 3475 6800
Wire Wire Line
	3875 6750 3875 6800
Wire Wire Line
	4275 6750 4275 6800
$Comp
L stepper_analyzer:TestPoint TP3
U 1 1 5DA4E91E
P 4275 6400
F 0 "TP3" H 4333 6518 50  0000 L CNN
F 1 "TestPoint" H 4333 6427 50  0001 L CNN
F 2 "stepper_analyzer:TestPoint_Loop_D1.80mm_Drill1.0mm_Beaded" H 4475 6400 50  0001 C CNN
F 3 "~" H 4475 6400 50  0001 C CNN
	1    4275 6400
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:TestPoint TP2
U 1 1 5DA4EE33
P 3875 6400
F 0 "TP2" H 3933 6518 50  0000 L CNN
F 1 "TestPoint" H 3933 6427 50  0001 L CNN
F 2 "stepper_analyzer:TestPoint_Loop_D1.80mm_Drill1.0mm_Beaded" H 4075 6400 50  0001 C CNN
F 3 "~" H 4075 6400 50  0001 C CNN
	1    3875 6400
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:TestPoint GND1
U 1 1 5DA4FBBB
P 4800 7100
F 0 "GND1" H 4700 7325 50  0000 L CNN
F 1 "TestPoint" H 4858 7127 50  0001 L CNN
F 2 "stepper_analyzer:TestPoint_Loop_D1.80mm_Drill1.0mm_Beaded" H 5000 7100 50  0001 C CNN
F 3 "~" H 5000 7100 50  0001 C CNN
	1    4800 7100
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:TestPoint TP1
U 1 1 5DA275D6
P 3475 6400
F 0 "TP1" H 3533 6518 50  0000 L CNN
F 1 "TestPoint" H 3533 6427 50  0001 L CNN
F 2 "stepper_analyzer:TestPoint_Loop_D1.80mm_Drill1.0mm_Beaded" H 3675 6400 50  0001 C CNN
F 3 "~" H 3675 6400 50  0001 C CNN
	1    3475 6400
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR014
U 1 1 5DA6D6E8
P 4800 7150
F 0 "#PWR014" H 4800 6900 50  0001 C CNN
F 1 "GND" H 4804 6995 50  0000 C CNN
F 2 "" H 4800 7150 50  0001 C CNN
F 3 "" H 4800 7150 50  0001 C CNN
	1    4800 7150
	1    0    0    -1  
$EndComp
Wire Wire Line
	3475 7100 3475 7150
Wire Wire Line
	3875 7100 3875 7150
Wire Wire Line
	4275 7100 4275 7150
Wire Wire Line
	4300 2500 4450 2500
$Comp
L Device:C_Small C4
U 1 1 5DAB5183
P 5750 3250
F 0 "C4" H 5950 3300 50  0000 C CNN
F 1 "0.22uF" H 5925 3400 50  0000 C CNN
F 2 "stepper_analyzer:C_0603_1608Metric" H 5750 3250 50  0001 C CNN
F 3 "~" H 5750 3250 50  0001 C CNN
	1    5750 3250
	-1   0    0    1   
$EndComp
$Comp
L stepper_analyzer:GND #PWR017
U 1 1 5DAB5918
P 5750 3400
F 0 "#PWR017" H 5750 3150 50  0001 C CNN
F 1 "GND" H 5754 3245 50  0000 C CNN
F 2 "" H 5750 3400 50  0001 C CNN
F 3 "" H 5750 3400 50  0001 C CNN
	1    5750 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5750 3150 5750 3100
Wire Wire Line
	5750 3100 5650 3100
Wire Wire Line
	5750 3350 5750 3400
$Comp
L stepper_analyzer:R_POT_US RV2
U 1 1 5DAF15AA
P 2525 6950
F 0 "RV2" H 2458 6996 50  0000 R CNN
F 1 "10K" H 2458 6905 50  0000 R CNN
F 2 "stepper_analyzer:Potentiometer_TT_P0915N" H 2525 6950 50  0001 C CNN
F 3 "~" H 2525 6950 50  0001 C CNN
	1    2525 6950
	1    0    0    1   
$EndComp
$Comp
L stepper_analyzer:R_POT_US RV1
U 1 1 5DA459B5
P 1625 6950
F 0 "RV1" H 1558 6996 50  0000 R CNN
F 1 "10K" H 1558 6905 50  0000 R CNN
F 2 "stepper_analyzer:Potentiometer_TT_P0915N" H 1625 6950 50  0001 C CNN
F 3 "~" H 1625 6950 50  0001 C CNN
	1    1625 6950
	1    0    0    1   
$EndComp
$Comp
L stepper_analyzer:GND #PWR02
U 1 1 5DB295C6
P 1625 7150
F 0 "#PWR02" H 1625 6900 50  0001 C CNN
F 1 "GND" H 1629 6995 50  0000 C CNN
F 2 "" H 1625 7150 50  0001 C CNN
F 3 "" H 1625 7150 50  0001 C CNN
	1    1625 7150
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR04
U 1 1 5DB29E97
P 2525 7150
F 0 "#PWR04" H 2525 6900 50  0001 C CNN
F 1 "GND" H 2529 6995 50  0000 C CNN
F 2 "" H 2525 7150 50  0001 C CNN
F 3 "" H 2525 7150 50  0001 C CNN
	1    2525 7150
	1    0    0    -1  
$EndComp
Wire Wire Line
	5500 5250 5500 5300
Wire Wire Line
	5900 5250 5900 5300
Wire Wire Line
	6650 5200 6650 5250
Wire Wire Line
	6650 5250 6800 5250
Connection ~ 6800 5250
Wire Wire Line
	6800 5250 6800 5300
Wire Wire Line
	6950 5200 6950 5250
Wire Wire Line
	6950 5250 6800 5250
Wire Wire Line
	3900 3150 3900 3100
$Comp
L stepper_analyzer:TestPoint CH2
U 1 1 5DC6D323
P 5100 3100
F 0 "CH2" H 5158 3218 50  0000 L CNN
F 1 "TestPoint" H 5158 3127 50  0001 L CNN
F 2 "stepper_analyzer:TestPoint_Loop_D1.80mm_Drill1.0mm_Beaded" H 5300 3100 50  0001 C CNN
F 3 "~" H 5300 3100 50  0001 C CNN
	1    5100 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5100 3100 5450 3100
Wire Wire Line
	4275 6400 4275 6450
Wire Wire Line
	3875 6400 3875 6450
Wire Wire Line
	3475 6400 3475 6450
Text GLabel 5050 2500 2    50   Input ~ 0
POT2
Text GLabel 7600 4500 2    50   Output ~ 0
LED1
Text GLabel 7600 4600 2    50   Output ~ 0
LED2
Text GLabel 7600 4700 2    50   Output ~ 0
LED3
Text GLabel 3425 6450 0    50   Input ~ 0
LED1
Text GLabel 3825 6450 0    50   Input ~ 0
LED2
Text GLabel 4225 6450 0    50   Input ~ 0
LED3
Text GLabel 2775 6950 2    50   Output ~ 0
POT2
Text GLabel 1875 6950 2    50   Output ~ 0
POT1
Wire Wire Line
	1875 6950 1775 6950
Wire Wire Line
	2775 6950 2675 6950
Wire Wire Line
	4800 7100 4800 7150
Wire Wire Line
	2525 7100 2525 7150
Wire Wire Line
	1625 7100 1625 7150
Wire Wire Line
	3425 6450 3475 6450
Connection ~ 3475 6450
Wire Wire Line
	3475 6450 3475 6550
Wire Wire Line
	3825 6450 3875 6450
Connection ~ 3875 6450
Wire Wire Line
	3875 6450 3875 6550
Wire Wire Line
	4225 6450 4275 6450
Connection ~ 4275 6450
Wire Wire Line
	4275 6450 4275 6550
Wire Wire Line
	5750 3100 6100 3100
Connection ~ 5750 3100
Wire Wire Line
	7500 4500 7600 4500
Wire Wire Line
	7500 4600 7600 4600
Wire Wire Line
	7500 4700 7600 4700
Wire Wire Line
	7500 3850 8800 3850
Wire Wire Line
	8800 3850 8800 4450
Wire Wire Line
	7500 3750 8900 3750
Wire Wire Line
	8900 3750 8900 4450
Wire Wire Line
	7500 3650 9000 3650
Wire Wire Line
	9000 3650 9000 4450
Wire Wire Line
	7500 3550 9100 3550
Wire Wire Line
	9100 3550 9100 4450
Wire Wire Line
	7500 3450 9200 3450
Wire Wire Line
	9200 3450 9200 4450
Wire Wire Line
	8600 4450 8350 4450
Wire Wire Line
	8350 4450 8350 4500
Wire Wire Line
	8700 4250 8700 4300
Wire Wire Line
	8600 4300 8700 4300
Connection ~ 8700 4300
Wire Wire Line
	8700 4300 8700 4450
Wire Wire Line
	8400 4300 8350 4300
Wire Wire Line
	8350 4300 8350 4450
Connection ~ 8350 4450
Wire Wire Line
	6100 4800 5900 4800
Wire Wire Line
	5900 4800 5900 4850
Wire Wire Line
	6100 4650 5500 4650
Wire Wire Line
	5500 4650 5500 4850
Wire Wire Line
	4700 2650 4700 3100
Wire Wire Line
	4700 3100 5100 3100
Connection ~ 5100 3100
Wire Wire Line
	5050 2500 4950 2500
$Comp
L stepper_analyzer:ACS70331 U2
U 1 1 5DAA891F
P 3900 2600
F 0 "U2" H 3350 3150 50  0000 C CNN
F 1 "ACS70331EESATR-2P5B3" H 3250 3000 50  0000 C CNN
F 2 "Sensor_Current:Allegro_QFN-12-10-1EP_3x3mm_P0.5mm" H 4300 2550 50  0001 L CIN
F 3 "" H 3900 2600 50  0001 C CNN
	1    3900 2600
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer-rescue:Teensy4-stepper_analyzer U3
U 1 1 5DAB0033
P 6800 4200
F 0 "U3" H 7250 3200 50  0000 C CNN
F 1 "Teensy 4,0" H 7300 3100 50  0000 C CNN
F 2 "stepper_analyzer:TEENSY40" H 6750 4200 50  0001 C CIN
F 3 "" H 6750 4200 50  0001 C CNN
	1    6800 4200
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR0104
U 1 1 5DAB146C
P 6800 5300
F 0 "#PWR0104" H 6800 5050 50  0001 C CNN
F 1 "GND" H 6804 5145 50  0000 C CNN
F 2 "" H 6800 5300 50  0001 C CNN
F 3 "" H 6800 5300 50  0001 C CNN
	1    6800 5300
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR0105
U 1 1 5DAB4768
P 8350 4500
F 0 "#PWR0105" H 8350 4250 50  0001 C CNN
F 1 "GND" H 8354 4345 50  0000 C CNN
F 2 "" H 8350 4500 50  0001 C CNN
F 3 "" H 8350 4500 50  0001 C CNN
	1    8350 4500
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR0108
U 1 1 5DAB662C
P 3900 3150
F 0 "#PWR0108" H 3900 2900 50  0001 C CNN
F 1 "GND" H 3904 2995 50  0000 C CNN
F 2 "" H 3900 3150 50  0001 C CNN
F 3 "" H 3900 3150 50  0001 C CNN
	1    3900 3150
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR0109
U 1 1 5DAB6E6E
P 3050 3350
F 0 "#PWR0109" H 3050 3100 50  0001 C CNN
F 1 "GND" H 3054 3195 50  0000 C CNN
F 2 "" H 3050 3350 50  0001 C CNN
F 3 "" H 3050 3350 50  0001 C CNN
	1    3050 3350
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR0111
U 1 1 5DAB78C7
P 4250 2050
F 0 "#PWR0111" H 4250 1800 50  0001 C CNN
F 1 "GND" H 4254 1895 50  0000 C CNN
F 2 "" H 4250 2050 50  0001 C CNN
F 3 "" H 4250 2050 50  0001 C CNN
	1    4250 2050
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:SW_Push SW1
U 1 1 5DAC18FD
P 5500 5050
F 0 "SW1" V 5546 5002 50  0000 R CNN
F 1 "SW_Push" V 5455 5002 50  0001 R CNN
F 2 "stepper_analyzer:SW_PUSH_6mm_H7.3mm" H 5500 5250 50  0001 C CNN
F 3 "~" H 5500 5250 50  0001 C CNN
	1    5500 5050
	0    -1   -1   0   
$EndComp
$Comp
L stepper_analyzer:GND #PWR018
U 1 1 5DB31CCE
P 5900 5300
F 0 "#PWR018" H 5900 5050 50  0001 C CNN
F 1 "GND" H 5904 5145 50  0000 C CNN
F 2 "" H 5900 5300 50  0001 C CNN
F 3 "" H 5900 5300 50  0001 C CNN
	1    5900 5300
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR016
U 1 1 5DB318D1
P 5500 5300
F 0 "#PWR016" H 5500 5050 50  0001 C CNN
F 1 "GND" H 5504 5145 50  0000 C CNN
F 2 "" H 5500 5300 50  0001 C CNN
F 3 "" H 5500 5300 50  0001 C CNN
	1    5500 5300
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:SW_Push SW2
U 1 1 5DAC40E3
P 5900 5050
F 0 "SW2" V 5946 5002 50  0000 R CNN
F 1 "SW_Push" V 5855 5002 50  0001 R CNN
F 2 "stepper_analyzer:SW_PUSH_6mm_H7.3mm" H 5900 5250 50  0001 C CNN
F 3 "~" H 5900 5250 50  0001 C CNN
	1    5900 5050
	0    -1   -1   0   
$EndComp
$Comp
L stepper_analyzer:MountingHole H1
U 1 1 5DA82431
P 8250 1350
F 0 "H1" H 8350 1396 50  0000 L CNN
F 1 "MountingHole" H 8350 1305 50  0000 L CNN
F 2 "stepper_analyzer:MountingHole_3.2mm_M3_Pad" H 8250 1350 50  0001 C CNN
F 3 "~" H 8250 1350 50  0001 C CNN
	1    8250 1350
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:MountingHole H2
U 1 1 5DA82BFF
P 9050 1350
F 0 "H2" H 9150 1396 50  0000 L CNN
F 1 "MountingHole" H 9150 1305 50  0000 L CNN
F 2 "stepper_analyzer:MountingHole_3.2mm_M3_Pad" H 9050 1350 50  0001 C CNN
F 3 "~" H 9050 1350 50  0001 C CNN
	1    9050 1350
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:MountingHole H4
U 1 1 5DA82DDA
P 8250 1600
F 0 "H4" H 8350 1646 50  0000 L CNN
F 1 "MountingHole" H 8350 1555 50  0000 L CNN
F 2 "stepper_analyzer:MountingHole_3.2mm_M3_Pad" H 8250 1600 50  0001 C CNN
F 3 "~" H 8250 1600 50  0001 C CNN
	1    8250 1600
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:MountingHole H3
U 1 1 5DA82F34
P 9050 1600
F 0 "H3" H 9150 1646 50  0000 L CNN
F 1 "MountingHole" H 9150 1555 50  0000 L CNN
F 2 "stepper_analyzer:MountingHole_3.2mm_M3_Pad" H 9050 1600 50  0001 C CNN
F 3 "~" H 9050 1600 50  0001 C CNN
	1    9050 1600
	1    0    0    -1  
$EndComp
Text Notes 4450 700  0    50   ~ 0
TODO: Verify pin numbers
Text Notes 4450 875  0    50   ~ 0
TODO: check footprints sizes
Connection ~ 2650 3350
$Comp
L stepper_analyzer:GND #PWR0103
U 1 1 5DAAF509
P 5250 4350
F 0 "#PWR0103" H 5250 4100 50  0001 C CNN
F 1 "GND" H 5254 4195 50  0000 C CNN
F 2 "" H 5250 4350 50  0001 C CNN
F 3 "" H 5250 4350 50  0001 C CNN
	1    5250 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	4600 4050 4950 4050
Connection ~ 4600 4050
Wire Wire Line
	3900 4050 4600 4050
$Comp
L stepper_analyzer:TestPoint CH1
U 1 1 5DAAE84C
P 4600 4050
F 0 "CH1" H 4658 4168 50  0000 L CNN
F 1 "TestPoint" H 4658 4077 50  0001 L CNN
F 2 "stepper_analyzer:TestPoint_Loop_D1.80mm_Drill1.0mm_Beaded" H 4800 4050 50  0001 C CNN
F 3 "~" H 4800 4050 50  0001 C CNN
	1    4600 4050
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:Jumper_3_Bridged12 JP1
U 1 1 5DAAD3D8
P 3900 3800
F 0 "JP1" H 3900 4004 50  0000 C CNN
F 1 "Jumper_3_Bridged12" H 3900 3913 50  0000 C CNN
F 2 "stepper_analyzer:PinHeader_1x03_P2.54mm_Vertical" H 3900 3800 50  0001 C CNN
F 3 "~" H 3900 3800 50  0001 C CNN
	1    3900 3800
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:GND #PWR0102
U 1 1 5DAAC454
P 2700 4450
F 0 "#PWR0102" H 2700 4200 50  0001 C CNN
F 1 "GND" H 2704 4295 50  0000 C CNN
F 2 "" H 2700 4450 50  0001 C CNN
F 3 "" H 2700 4450 50  0001 C CNN
	1    2700 4450
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:ACS70331 U1
U 1 1 5DAA9FDD
P 2700 3900
F 0 "U1" H 2050 3600 50  0000 C CNN
F 1 "ACS70331EESATR-2P5B3" H 2050 3275 50  0000 C CNN
F 2 "Sensor_Current:Allegro_QFN-12-10-1EP_3x3mm_P0.5mm" H 3100 3850 50  0001 L CIN
F 3 "" H 2700 3900 50  0001 C CNN
	1    2700 3900
	1    0    0    -1  
$EndComp
Wire Wire Line
	4150 3800 4200 3800
Text GLabel 4200 3800 2    50   Input ~ 0
POT1
Wire Wire Line
	5250 4300 5250 4350
Wire Wire Line
	5250 4100 5250 4050
Wire Wire Line
	5150 4050 5250 4050
Wire Wire Line
	3900 4050 3900 3950
Wire Wire Line
	3100 3800 3650 3800
Wire Wire Line
	2700 4400 2700 4450
Connection ~ 2600 4400
Wire Wire Line
	2500 4400 2600 4400
Wire Wire Line
	2500 4300 2500 4400
$Comp
L Device:R_Small_US R4
U 1 1 5DA26250
P 5050 4050
F 0 "R4" V 4845 4050 50  0000 C CNN
F 1 "330R" V 4936 4050 50  0000 C CNN
F 2 "stepper_analyzer:R_0603_1608Metric" H 5050 4050 50  0001 C CNN
F 3 "~" H 5050 4050 50  0001 C CNN
	1    5050 4050
	0    1    1    0   
$EndComp
$Comp
L Device:C_Small C3
U 1 1 5DA254E5
P 5250 4200
F 0 "C3" H 5075 4200 50  0000 C CNN
F 1 "0.22uF" H 5000 4300 50  0000 C CNN
F 2 "stepper_analyzer:C_0603_1608Metric" H 5250 4200 50  0001 C CNN
F 3 "~" H 5250 4200 50  0001 C CNN
	1    5250 4200
	-1   0    0    1   
$EndComp
Wire Wire Line
	2900 4400 2900 4300
Wire Wire Line
	2800 4300 2800 4400
Connection ~ 2800 4400
Wire Wire Line
	2800 4400 2900 4400
Wire Wire Line
	2700 4300 2700 4400
Connection ~ 2700 4400
Wire Wire Line
	2700 4400 2800 4400
Wire Wire Line
	2600 4300 2600 4400
Wire Wire Line
	2600 4400 2700 4400
Wire Wire Line
	2650 3350 2650 3500
$Comp
L stepper_analyzer:TFT U4
U 1 1 5DAB2B30
P 8950 5200
F 0 "U4" H 8350 5000 50  0000 L CNN
F 1 "TFT" H 8350 4900 50  0000 L CNN
F 2 "stepper_analyzer:DIP-TFT" H 8950 5200 50  0001 C CIN
F 3 "" H 8950 5200 50  0001 C CNN
	1    8950 5200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5250 4050 6100 4050
Connection ~ 5250 4050
Text Notes 4450 1050 0    50   ~ 0
TODO: check netlist
Text Notes 8400 5900 0    50   ~ 0
1.8" 128x160 pixels, color TFT\nSPI, ST7735 controller
Wire Notes Line
	5275 5900 5275 7550
Wire Notes Line
	1200 7550 1200 5900
Text Notes 1200 5800 0    50   ~ 0
Optional, for firmware developement.
Wire Wire Line
	2100 3750 1900 3750
Wire Wire Line
	1400 1800 1400 2100
Wire Wire Line
	1400 2100 2300 2100
Wire Wire Line
	2300 2100 2300 1800
Wire Wire Line
	1700 1800 1700 2000
Wire Wire Line
	1700 2000 2600 2000
Wire Wire Line
	2600 2000 2600 1800
Wire Wire Line
	1600 1800 1600 4050
Wire Wire Line
	1600 4050 2100 4050
Wire Wire Line
	1500 1800 1500 2750
Wire Wire Line
	1500 2750 3300 2750
Wire Wire Line
	2400 2450 3300 2450
Wire Wire Line
	2400 1800 2400 2450
Wire Wire Line
	2500 1800 2500 2200
Wire Wire Line
	2500 2200 1900 2200
Wire Wire Line
	1900 2200 1900 3750
Wire Wire Line
	6600 2050 6600 2000
$Comp
L stepper_analyzer:GND #PWR0112
U 1 1 5DC777F8
P 7150 2050
F 0 "#PWR0112" H 7150 1800 50  0001 C CNN
F 1 "GND" H 7154 1895 50  0000 C CNN
F 2 "" H 7150 2050 50  0001 C CNN
F 3 "" H 7150 2050 50  0001 C CNN
	1    7150 2050
	1    0    0    -1  
$EndComp
Wire Wire Line
	7150 2000 7150 2050
$Comp
L stepper_analyzer:SW_DIP_x04 SW3
U 1 1 5DC6C322
P 6800 2350
F 0 "SW3" V 6950 2900 50  0000 R CNN
F 1 "SW_DIP_x04" V 6800 3150 50  0001 R CNN
F 2 "stepper_analyzer:SW_DIP_SPSTx04_Slide_Copal_CHS-04B_W7.62mm_P1.27mm" H 6800 2350 50  0001 C CNN
F 3 "~" H 6800 2350 50  0001 C CNN
	1    6800 2350
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6700 2050 6700 2000
Wire Wire Line
	6600 2000 6700 2000
Connection ~ 6700 2000
Wire Wire Line
	6800 2050 6800 2000
Wire Wire Line
	6700 2000 6800 2000
Connection ~ 6800 2000
Wire Wire Line
	6900 2050 6900 2000
Wire Wire Line
	6800 2000 6900 2000
Wire Wire Line
	6900 2000 7150 2000
Connection ~ 6900 2000
Wire Wire Line
	6600 2650 6600 2750
Wire Wire Line
	6700 2650 6700 2750
Wire Wire Line
	6800 2650 6800 2750
Wire Wire Line
	6900 2650 6900 2750
Text Notes 6500 1900 0    50   ~ 0
CONFIGURATION\nSWITCHES
Text Notes 1350 1450 0    50   ~ 0
To Stepper\nController
$Comp
L Device:R_Small_US R6
U 1 1 5DB2651A
P 2075 6450
F 0 "R6" H 1875 6550 50  0000 C CNN
F 1 "400R" H 1875 6450 50  0000 C CNN
F 2 "stepper_analyzer:R_0603_1608Metric" H 2075 6450 50  0001 C CNN
F 3 "~" H 2075 6450 50  0001 C CNN
	1    2075 6450
	1    0    0    -1  
$EndComp
Wire Wire Line
	1625 6650 2075 6650
Wire Wire Line
	1625 6650 1625 6800
Wire Wire Line
	2525 6650 2525 6800
Wire Wire Line
	2075 6550 2075 6650
Wire Wire Line
	2075 6350 2075 6300
Connection ~ 2075 6650
Wire Wire Line
	2075 6650 2525 6650
Text Notes 2275 6600 0    50   ~ 0
3VDC
Text Notes 2850 1300 0    50   ~ 0
Connectors J1, J2 are\ninterchangeable
Text Notes 3125 2425 0    50   ~ 0
I2
Text Notes 1975 3725 0    50   ~ 0
I1\n
Text Notes 5700 2350 0    50   ~ 0
SMD 1.27mm pitch\n
Text Notes 5800 5750 0    50   ~ 0
RIGHT\nBUTTON
Text Notes 5350 5750 0    50   ~ 0
LEFT\nBUTTON
Text Label 1600 1900 0    50   ~ 0
B
Text Label 1700 1900 0    50   ~ 0
~B
Text Label 1400 1900 2    50   ~ 0
~A
Text Label 1500 1900 2    50   ~ 0
A
Text Notes 2325 1475 0    50   ~ 0
A
Text Notes 2525 1475 0    50   ~ 0
B
Text Notes 4450 1225 0    50   ~ 0
TODO: add stepper motor symbol after completing the pcb layout
NoConn ~ 7500 4150
Text Notes 6275 6550 0    50   ~ 0
Resistors, capacitors and LEDS are 0603 SMD packages.
$Comp
L stepper_analyzer:3V3A #PWR0101
U 1 1 5DB84904
P 3850 1900
F 0 "#PWR0101" H 3850 1750 50  0001 C CNN
F 1 "3V3A" H 3865 2073 50  0000 C CNN
F 2 "" H 3850 1900 50  0001 C CNN
F 3 "" H 3850 1900 50  0001 C CNN
	1    3850 1900
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:3V3A #PWR0106
U 1 1 5DB851D9
P 2650 3200
F 0 "#PWR0106" H 2650 3050 50  0001 C CNN
F 1 "3V3A" H 2665 3373 50  0000 C CNN
F 2 "" H 2650 3200 50  0001 C CNN
F 3 "" H 2650 3200 50  0001 C CNN
	1    2650 3200
	1    0    0    -1  
$EndComp
$Comp
L stepper_analyzer:3V3A #PWR0107
U 1 1 5DB85717
P 2075 6300
F 0 "#PWR0107" H 2075 6150 50  0001 C CNN
F 1 "3V3A" H 2090 6473 50  0000 C CNN
F 2 "" H 2075 6300 50  0001 C CNN
F 3 "" H 2075 6300 50  0001 C CNN
	1    2075 6300
	1    0    0    -1  
$EndComp
Wire Wire Line
	7500 3050 7600 3050
$Comp
L stepper_analyzer:3V3D #PWR0110
U 1 1 5DB861CB
P 7600 3150
F 0 "#PWR0110" H 7600 3000 50  0001 C CNN
F 1 "3V3D" V 7615 3278 50  0000 L CNN
F 2 "" H 7600 3150 50  0001 C CNN
F 3 "" H 7600 3150 50  0001 C CNN
	1    7600 3150
	0    1    1    0   
$EndComp
$Comp
L stepper_analyzer:3V3D #PWR0113
U 1 1 5DB871AF
P 8700 4250
F 0 "#PWR0113" H 8700 4100 50  0001 C CNN
F 1 "3V3D" H 8675 4425 50  0000 C CNN
F 2 "" H 8700 4250 50  0001 C CNN
F 3 "" H 8700 4250 50  0001 C CNN
	1    8700 4250
	1    0    0    -1  
$EndComp
Wire Wire Line
	7500 3150 7600 3150
$Comp
L stepper_analyzer:3V3A #PWR0114
U 1 1 5DB8D3EF
P 7600 3050
F 0 "#PWR0114" H 7600 2900 50  0001 C CNN
F 1 "3V3A" V 7615 3178 50  0000 L CNN
F 2 "" H 7600 3050 50  0001 C CNN
F 3 "" H 7600 3050 50  0001 C CNN
	1    7600 3050
	0    1    1    0   
$EndComp
Text Notes 1575 5000 0    50   ~ 0
+/- 2.5A isolated current sensor\nVout = 1.5V +/- 0.4V per Amp.\n
Wire Notes Line
	1200 5900 5275 5900
Wire Notes Line
	1200 7550 5275 7550
$Comp
L stepper_analyzer:Stepper_Motor_bipolar M?
U 1 1 5DB96B5F
P 2300 1325
F 0 "M?" H 2350 1725 50  0001 L CNN
F 1 "Stepper_Motor_bipolar" H 2200 1675 50  0001 L TNN
F 2 "" H 2310 1415 50  0001 C CNN
F 3 "http://www.infineon.com/dgdl/Application-Note-TLE8110EE_driving_UniPolarStepperMotor_V1.1.pdf?fileId=db3a30431be39b97011be5d0aa0a00b0" H 2310 1415 50  0001 C CNN
	1    2300 1325
	1    0    0    -1  
$EndComp
$EndSCHEMATC
