EESchema Schematic File Version 4
LIBS:isp_adapter-cache
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
L project_library:pogo_pin PIN1
U 1 1 5C0FE002
P 4200 4300
F 0 "PIN1" V 4250 4350 50  0000 C CNN
F 1 "pogo_pin" H 4200 4500 50  0001 C CNN
F 2 "footprints:pogo_horizontal" H 4400 4300 50  0001 C CNN
F 3 "~" H 4400 4300 50  0001 C CNN
	1    4200 4300
	-1   0    0    1   
$EndComp
$Comp
L project_library:pogo_pin PIN2
U 1 1 5C0FE0AB
P 4500 4300
F 0 "PIN2" V 4550 4350 50  0000 C CNN
F 1 "pogo_pin" H 4500 4500 50  0001 C CNN
F 2 "footprints:pogo_horizontal" H 4700 4300 50  0001 C CNN
F 3 "~" H 4700 4300 50  0001 C CNN
	1    4500 4300
	-1   0    0    1   
$EndComp
$Comp
L project_library:pogo_pin PIN5
U 1 1 5C0FE0C6
P 5250 4300
F 0 "PIN5" V 5300 4350 50  0000 C CNN
F 1 "pogo_pin" H 5250 4500 50  0001 C CNN
F 2 "footprints:pogo_horizontal" H 5450 4300 50  0001 C CNN
F 3 "~" H 5450 4300 50  0001 C CNN
	1    5250 4300
	-1   0    0    1   
$EndComp
$Comp
L project_library:pogo_pin PIN6
U 1 1 5C0FE0DB
P 5500 4300
F 0 "PIN6" V 5550 4350 50  0000 C CNN
F 1 "pogo_pin" H 5500 4500 50  0001 C CNN
F 2 "footprints:pogo_horizontal" H 5700 4300 50  0001 C CNN
F 3 "~" H 5700 4300 50  0001 C CNN
	1    5500 4300
	-1   0    0    1   
$EndComp
$Comp
L project_library:pogo_pin PIN7
U 1 1 5C0FE0F2
P 5750 4300
F 0 "PIN7" V 5800 4350 50  0000 C CNN
F 1 "pogo_pin" H 5750 4500 50  0001 C CNN
F 2 "footprints:pogo_horizontal" H 5950 4300 50  0001 C CNN
F 3 "~" H 5950 4300 50  0001 C CNN
	1    5750 4300
	-1   0    0    1   
$EndComp
$Comp
L project_library:pogo_pin PIN8
U 1 1 5C0FE10B
P 6000 4300
F 0 "PIN8" V 6050 4350 50  0000 C CNN
F 1 "pogo_pin" H 6000 4500 50  0001 C CNN
F 2 "footprints:pogo_horizontal" H 6200 4300 50  0001 C CNN
F 3 "~" H 6200 4300 50  0001 C CNN
	1    6000 4300
	-1   0    0    1   
$EndComp
$Comp
L Connector_Generic:Conn_02x03_Odd_Even J1
U 1 1 5C0FE2D4
P 6550 3200
F 0 "J1" H 6300 3400 50  0000 C CNN
F 1 "ICSP" H 6350 3500 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03_Pitch2.54mm" H 6550 3200 50  0001 C CNN
F 3 "~" H 6550 3200 50  0001 C CNN
	1    6550 3200
	1    0    0    -1  
$EndComp
Wire Wire Line
	6350 3300 6000 3300
Wire Wire Line
	6000 3300 6000 4300
Wire Wire Line
	6350 3200 5750 3200
Wire Wire Line
	5750 3200 5750 4300
Wire Wire Line
	6350 3100 5500 3100
Wire Wire Line
	5500 3100 5500 4300
Wire Wire Line
	6850 3300 7150 3300
Wire Wire Line
	7150 3300 7150 3800
Wire Wire Line
	4500 3800 4500 4300
Wire Wire Line
	6850 3200 7300 3200
Wire Wire Line
	7300 3200 7300 3950
Wire Wire Line
	7300 3950 5250 3950
Wire Wire Line
	5250 3950 5250 4300
Wire Wire Line
	6850 3100 7300 3100
Wire Wire Line
	7300 3100 7300 2800
Wire Wire Line
	4200 2800 4200 4300
Text Notes 4250 4750 1    50   ~ 0
+3.6V
Text Notes 4550 4750 1    50   ~ 0
GND
Text Notes 5300 4750 1    50   ~ 0
MOSI
Text Notes 5550 4750 1    50   ~ 0
MISO
Text Notes 5800 4750 1    50   ~ 0
SCK
Text Notes 6050 4750 1    50   ~ 0
RESET
Text Notes 7100 6900 0    150  ~ 0
Soap Dispenser ICSP Adapter
Wire Notes Line
	4750 4450 4750 4250
Wire Notes Line
	5000 4450 5000 4250
Wire Wire Line
	4500 3800 7150 3800
Wire Wire Line
	4200 2800 7300 2800
$EndSCHEMATC
