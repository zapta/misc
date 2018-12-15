Running Arduino firmware on a GOJO 700 mL LTX-7 GOJO soap dispenser.

This project is an learning experience in running Arduino based software on an
off the shelf appliance. I used a GOJO soap dispense model 700 mL LTX-7 GOJO though
other models may work in a similar way.

The board is based on an Atmel ATTiny48 that operates on 3.6V regulated from
a 6V input from 4 batteries. The board has several hardware peripherals,
a door switch, an H bridge motor control, motor position micro switch, 
door closed swith, dual color LED, IR proximity sensor, RFID transiver, 
and current and voltage sensors.  A partial sechematic that covers
the MCU and the peripherals I used is vailable in this project in KiCad
and in PDF formats.

Programming the MCU from the Arduio IDE is done using an ISP programmer
and the standard 6 ISP pins are available on the edge of the board
via unused wire pads.

To demonstrate the usability of the board I wrote a sample Arduino 
program that performs the basic functionalities of soap dispensing and 
cover aspects such as reading the sensing inputs, activating the motor
(both forward and brake modes) and using the sleep mode of the MCU
to preserve battery power. As of Dec 2018 it doesn't cover aspects
such as voltage and current sensing and using the RFID transiver. 

TODO: edit for clarity.
TODO: add pictures
TODO: add links to schema and Arduino program.
TODO: add ISP instructions.

