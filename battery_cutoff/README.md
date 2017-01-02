Arduino car battery monitor/cutoff.

This is a custom Arduino board that monitors and controsl 12V DC in car environment.
It contains an ATMEGA328P MCU that monitors the battery voltage and controls an output
relay. 

The Arduino sketch that I am using with this board detects engine cranking pattern on the 
battery line and disconnects the output voltage to the streaming BT adapter for 
1 second. This resets the BT adapter and causes it to pair with my phone (the 
12VDC socket in my car mentain power even after I turn the engine off which causes
the BT adapter not to pair with my phone when I come back to the car).

The board is not specific to this applictaion and with different sketch can do
other battery monitoring/cutoff operations.

The board is compatible with the Arduino IDE (it acts as an Arduino Mini Pro 5V 16Mhz).

The 3d subdirectory here includes a model for a 3d printable snap-on enclosure. You
can find there both the OpenSCAD source file and the gnerated STL file. The PCB 
is attached to the base of the encolsure using a double side 3M adhesive tape 
such as this one https://www.amazon.com/dp/B00OI6E0L2 .

