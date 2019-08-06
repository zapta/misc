                   .:                     :,                                          
,:::::::: ::`      :::                   :::                                          
,:::::::: ::`      :::                   :::                                          
.,,:::,,, ::`.:,   ... .. .:,     .:. ..`... ..`   ..   .:,    .. ::  .::,     .:,`   
   ,::    :::::::  ::, :::::::  `:::::::.,:: :::  ::: .::::::  ::::: ::::::  .::::::  
   ,::    :::::::: ::, :::::::: ::::::::.,:: :::  ::: :::,:::, ::::: ::::::, :::::::: 
   ,::    :::  ::: ::, :::  :::`::.  :::.,::  ::,`::`:::   ::: :::  `::,`   :::   ::: 
   ,::    ::.  ::: ::, ::`  :::.::    ::.,::  :::::: ::::::::: ::`   :::::: ::::::::: 
   ,::    ::.  ::: ::, ::`  :::.::    ::.,::  .::::: ::::::::: ::`    ::::::::::::::: 
   ,::    ::.  ::: ::, ::`  ::: ::: `:::.,::   ::::  :::`  ,,, ::`  .::  :::.::.  ,,, 
   ,::    ::.  ::: ::, ::`  ::: ::::::::.,::   ::::   :::::::` ::`   ::::::: :::::::. 
   ,::    ::.  ::: ::, ::`  :::  :::::::`,::    ::.    :::::`  ::`   ::::::   :::::.  
                                ::,  ,::                               ``             
                                ::::::::                                              
                                 ::::::                                               
                                  `,,`


https://www.thingiverse.com/thing:2254103
HyperCube Evolution by SCOTT_3D is licensed under the Creative Commons - Attribution license.
http://creativecommons.org/licenses/by/3.0/

# Summary

The HyperCube Evolution 3D Printer is a CoreXY printer inspired by the excellent HyperCube 3D Printer developed by Tech2C. The belt arrangement on that printer was the neatest CoreXY arrangement that I have seen.

I have leveraged the great work that Tech2C has done to refine his design and incorporated this with my own further development to reduce the number of printed parts and simplify the build.

Design goals for the HyperCube Evolution 3D Printer:

1. Increase the stiffness of the printer to further improve / reduce vibration artefacts.
	- 3030 extrusion used for the frame
	- 2020 extrusion used for the build platform frame
	- 8mm diameter X rails
	- 10mm diameter Y rails
	- 12mm diameter Z rails

2. Minimise the size of the printer for the chosen build volume.
	- Parametric CAD design in Autodesk Inventor
	- Excel spreadsheet provided to allow for customised printer size

The prototype printer, with a build volume of 300 x 300 x 300, met with all expectation but did show some small bed vibrations when printing at high speed due to the large bed and counter levered design. Therefore, two build options are available. A single Z axis version for smaller build platforms and a double Z axis version for larger beds or those wishing for a rock solid build platform.

The Evolution also features a quick attach X carriage to allow for interchangeable tools e.g. the extruder mount and a DTI mount for tramming the build platform.

More to come over the next few weeks as I'm awaiting parts for upgrade the prototype to use the double Z axis, and also the parts to convert my Geetech Prusa i3 into another HyperCube Evolution.

Facebook Group: https://www.facebook.com/groups/Hypercubeevolution/

<strong>Changelog:</strong>

20.04.2017 Configuration file updated, multiple size Bed Brackets added
22.04.2017 BOM added
23.04.2017 Introduction video added https://www.youtube.com/watch?v=1rctCsUGnX8&feature=youtu.be
23.04.2017 Added 4 variations of Y carriage to suit different combinations of 8mm and 10mm rails. Plus bearing clamps to suit. Note - current X carriage only suits LM8UU bearings. An adaptor will be needed to use 10mm bushings.
30.04.2017 Error found in spreadsheet which resulted in 10mm rails being 30mm too long. Version 1.2 uploaded.
09.05.2017 Version 1.1 Z Axis Linear Rail Bracket - Double Z - Left & Right. 
13.05.2017 Version 1.1 Z Nut Bracket - modified for easier assembly
13.05.2017 Z Nut Bracket for T10 leadscrew added
27.05.2017 Configuration file updated to include part print list (note that some part versions are still not available)
02.06.2017 Repetier configuration file uploaded
17.06.2017 40mm bed bracket added
17.06.2017 v1.1 versions of XY Stepper Mount and Idler Mount added which have slotted screw holes for different L brackets. v1.0 versions remain for those who don't need the slot.
17.06.2017 v1.1 of XY Stepper Mount and Idler Mount for 8mm diameter Y linear rails
18.06.2017 v1.4 configuration file added.. Thanks to Nicolas Harscoat for adding the shaft selector which then determines the part versions to be printed.
01.07.2017 CAD files uploaded for v1.0 as a pack and go. So the assembly should work. Note that some published parts are now v1.0+, but these files should get people going.
22.07.2017 Mounts for Full Graphic Controller added

<strong>BOM</strong>

<strong>Frame and linear guides</strong> – use the Excel spreadsheet to calculate the lengths required for your custom size.

3030 and 2020 extrusion
https://www.aliexpress.com/item/Customized-3030W-Aluminum-Extrusion-Profile-Free-cutting-in-any-Length-Black-Color/32799761497.html?spm=2114.13010608.0.0.GpQMwK

16 x L type bracket for 3030 extrusion
https://www.aliexpress.com/item/T-slot-L-type-90-degree-EU-standard-3030-aluminum-profile-Inside-corner-connector-bracket-with/32772827830.html?spm=2114.13010608.0.0.vwn135

8 x 3030 corner brackets
https://www.aliexpress.com/item/20pcs-lots-3030-corner-fitting-angle-aluminum-35-x-35-L-connector-bracket-fastener-match-use/32733275167.html?spm=2114.13010608.0.0.mTb6EB

<strong>Fasteners</strong>

M6 x 10 Button head screws - 6 off required for mounting of Stepper Motor Brackets and XY Idler Brackets

M5 x 10 Button head screws
https://www.aliexpress.com/item/100pcs-lot-M5-10-Bolt-A2-70-ISO7380-Button-Head-Socket-Screw-Bolt-SUS304-Stainless-Steel/32328885247.html?spm=2114.13010608.0.0.vwn135

M3 Socket head screws
https://www.aliexpress.com/item/Hex-Socket-Head-Cap-Screw-M3-Qty-90pcs-in-Box-Assortment-Kits-SUS-304-M3-4/32334431524.html?spm=2114.13010608.0.0.vwn135

100pcs M5 T Hammer Nuts for 3030 extrusion
https://www.aliexpress.com/item/100pcs-30-M5-hammer-nut-M5-block-t-slot-nuts-for-3030-aluminum-profile-extrusion-Slot/32688393400.html?spm=2114.13010608.0.0.vwn135

100pcs M5 T Hammer Nuts for 2020 extrusion
https://www.aliexpress.com/item/M5-T-Nut-Hammer-Nut-Aluminum-Connector-T-Fastener-Sliding-Nut-Nickel-Plated-Carbon-Steel-for/32619352982.html?spm=2114.13010608.0.0.mTb6EB

4 x 3mm dowel pins
https://www.aliexpress.com/item/GB119-304-Stainless-Steel-Cylindrical-Pin-Locating-Pin-M3-12/32789184323.html?spm=2114.13010608.0.0.iDrnoz

100pcs M3 5x5 Brass knurled insert
http://www.banggood.com/100pcs-M3x5x5mm-Metric-Threaded-Brass-Knurl-Round-Insert-Nuts-p-1050182.html?rmmds=search


<strong>Motors</strong>

1 or 2 x NEMA 17 Lead Screw M8 – length needs to be ~30mm longer than required Z travel, depending on nut type
https://www.aliexpress.com/item/New-3D-Printer-NEMA-17-Lead-Screw-300mm-Stepper-Motor-Z-Axis-3D-Printer-KIT-Step/32579962696.html?spm=2114.13010608.0.0.UfVwc7

3 x NEMA 17 42mm Stepper Motors
https://www.aliexpress.com/item/CE-certification-3pcs-4-lead-Nema17-Stepper-Motor-42-motor-D-shaft-motor-42BYGH-1-7A/32786907415.html?spm=2114.13010608.0.0.vwn135

<strong>Pulleys and Belts</strong>

2 x GT2 Timing Pulley (20 teeth) 5mm bore for 6mm belt
6 x GT2 Idler Pulley (20 teeth) 3mm bore
2 x GT2 Idler Pulley without teeth (20 teeth) 3mm bore
5m Polyurethane GT2 6mm belt
https://www.aliexpress.com/item/5-Meter-Polyurethane-GT2-6mm-Open-Timing-Belt-Width-6mm-GT2-2GT-Belt-For-3D-Printer/32616409980.html?spm=2114.13010608.0.0.mTb6EB

<strong>Linear Bearings</strong>

4 x LM12UU 12mm Linear Ball Bearings
4 x LM10UU 10mm Linear Ball Bearings or 2 x LM10LUU 10mm Long Linear Ball Bearings
4 x LM8UU 8mm Linear Ball Bearings

<strong>Heated Bed components</strong>

1 x Heated Bed 300x300
https://www.aliexpress.com/item/For-RepRap-3D-Prusa-Mendel-Printer-MK2A-300-300-3-0mm-Heater-Bed-RAMPS-1-4/32668984871.html?spm=2114.13010608.0.0.vwn135

4 or 6 x Levelling screws
https://www.aliexpress.com/item/3D-printer-Leveling-components-M3-screw-Leveling-spring-Leveling-knob-suite-free-shipping-M3-40-IMG/32562830096.html?spm=2114.13010608.0.0.vwn135

1 x 100kohm NTC3950 thermistor
https://www.aliexpress.com/item/1pcs-3d-printer-parts-100K-ohm-NTC-3950-Thermistors-with-cable-for-3D-Printer-Reprap-Mend/32489800025.html?spm=2114.13010608.0.0.vwn135

<strong>Control System</strong>

1 x 24V 400W power supply
https://www.aliexpress.com/item/Best-quality-24V-16-7A-400W-Switching-Power-Supply-Driver-for-LED-Strip-AC-100-240V/32318296978.html?spm=2114.13010608.0.0.vwn135

1 x RAMPS 1.4 with stepper drivers and display – NOTE: This board needs to be modified to run a 24V system. If you don’t then you will kill the Arduino Mega!
https://www.aliexpress.com/item/5pcs-A4988-Stepper-Driver-Module-with-Heatsink-1pcs-RAMPS-1-4-Controller-RAMPS1-4-LCD-12864/1869163278.html?spm=2114.13010608.0.0.0rKDs5

1 x RAMPS 1.4 fan extender module – use to run the 12V fans
https://www.aliexpress.com/item/Free-shipping-3D-Printer-Reprap-Ramps1-4-RRD-Fan-Extender-Max-20V-Fan-Expansion-Module/1804966614.html?spm=2114.13010608.0.0.rT5D2f

1 x DC-DC 24V-12V step down module
https://www.aliexpress.com/item/DC-DC-24V-18V-to-12V-3A-Step-Down-Module-MINI-Buck-Converter-Power-Supply-Circuit/32778770850.html?spm=2114.13010608.0.0.G2tjiK

1 x Arduino MEGA 2560
https://www.aliexpress.com/item/Mega-2560-CH340G-ATmega2560-16AU-Compatible-for-Arduino-Mega-2560/32517341214.html?spm=2114.13010608.0.0.O0iWmT

1 x Power expansion module (if needed)
https://www.aliexpress.com/item/for-3D-Printer-General-Add-on-Heated-Bed-Power-Expansion-Module-High-Power-Module-expansion-board/32706099435.html?spm=2114.13010608.0.0.vwn135

1 x 5V NPN M12 inductive sensor
https://www.aliexpress.com/item/M12-4mm-detection-5VDC-NPN-NO-LJ12A3-4-Z-BX-5V-cylinder-inductive-proximity-sensor-switch/32553311139.html?spm=2114.13010608.0.0.iDrnoz

4 x Optical end stops
https://www.aliexpress.com/item/2016-Newest-1-x-Optical-Endstop-End-Stop-Limit-Switch-Solution-for-3D-Printer-or-CNC/32656689805.html?spm=2114.01010208.3.9.TjpVYa&ws_ab_test=searchweb0_0,searchweb201602_3_10152_10065_10151_10068_10136_10137_10060_10138_10155_10062_10156_10134_10154_10056_10055_10054_10059_10099_10103_10102_10096_10148_10147_10052_10053_10142_10107_10050_10051_10084_10083_10080_10082_10081_10177_10110_10111_10112_10113_10114_10181_10037_10033_10032_10078_10079_10077_10073_10070_10123_10124,searchweb201603_2,afswitch_1,ppcSwitch_7&btsid=0a677c30-15c5-4511-bd9b-21cec7f98719&algo_expid=9458fd9d-18ca-4360-9463-2e064369527b-4&algo_pvid=9458fd9d-18ca-4360-9463-2e064369527b

<strong>Cable</strong>

5m x 24AWG 4 core UL2464 cable 
https://www.aliexpress.com/item/1M-UL-2464-2C-3C-4C-24-AWG-Multi-core-PVC-jacket-cable-Tinned-copper-wire/32781273770.html?spm=2114.13010608.0.0.O0iWmT

5m x 24AWG Red Black cable
https://www.aliexpress.com/item/IEKOV-5-M-Tinned-copper-24AWG-2-pin-Red-Black-cable-300V-PVC-insulated-wire-Electric/32649240375.html?spm=2114.13010608.0.0.O0iWmT

2m x 14AWG Silicone cable
https://www.aliexpress.com/item/14AWG-Flexible-Silicone-Wire-Cable-Soft-High-Temperature-Tinned-copper-UL-1M/32653995219.html?spm=2114.13010608.0.0.vwn135

5m x Servo extension cable
https://www.aliexpress.com/item/servo-JR-color-extension-cable-3p-line-futaba-jr-model-aircraft-model-wiring-Wholesale-30-core/32610086634.html?spm=2114.13010608.0.0.vwn135

Connectors for Stepper motors
https://www.aliexpress.com/item/20-Sets-Micro-JST-2-0-PH-6-Pin-Connector-plug-Male-Female-Crimps/32399923294.html?spm=2114.13010608.0.0.X3vJKL


# Print Settings

Printer: HyperCube Evolution
Rafts: No
Supports: Yes
Resolution: 0.2mm
Infill: 25 - 50%