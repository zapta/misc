/* [Hidden] */
// This is based on the original by Dave (dmould) - thank you
// Updated 2016-01-03 to support version 1.1 PanelDue board and support Thingiverse customiser

// Print variables:
// 1) There is an overhang as the case starts printing in order to print the rounded front edges.
//    So long as the MMRadius (MMMRad) is small and the first layer height on the 3D printer is 
//    not too thin the printer should cope.  If however the overhang proves to be too much to
//    print set the "RelieveOverhang" variable non-zero up to 100 and the initial overhang will
//    be reduced proportionately to that number at the expense of a less rounded edge.
//	  (A value less than 30 is usually plenty sufficient).  Set to 100 to see the effect.
// 2) Set the "ShowPCB" variable to "true" to show the PCB shapes.
//    This is only in order to see how the PCBs will fit in the case, and should
//    not be used when generating an STL to print

/* [Size] */

// Which display panel do you have?
DisplayType=3;					// [1:Itead ITDB02-4.3,2:Itead ITDB02-5.0,3:Standard 4.3 inch,4:Standard 5 inch,5:7 inch]

// Which version PanelDue controller board do you have?
BoardVersion=2.0;				// [1.0,1.1,2.0,3.0]

/* [Options] */

// Do you want cutouts and mounting holes for a lid?
Lid=0;								// [0:No,1:Yes]

// Do you want a lip at the top for hanging the enclosure from a top horizontal extrusion?
Lip=0;								// [0:No,1:Yes]

// Do you want a slot for the SD card?
SD_card=1;						// [0:No,1:Yes]

// How much do you want to relieve the overhang of the rounded corners, to make it easier to print?
RelieveOverhang=10;				// [0:30]

/* [Hidden] */

/*
// Do you want a ball-and-socket mount?
Mount=0;							// [0:No,1:Yes]
*/

screw=false;						// set if screw lid
Encoder=false;					// true if hole wanted for rotary encoder (version 1.0 board only)

// Set ONE of the following 4 variables true according to your display type
Itead43=(DisplayType==1);
Itead50=(DisplayType==2);
Other43=(DisplayType==3);
Other50=(DisplayType==4);
Other70=(DisplayType==5);

// Set up the main enclosure parameters
MWall=2.4;						// Main box MWall thickness (multiple of extrusion width)
MBase=2;							// Main box MBase (front panel) thickness
MRad=MWall;						// MMRadius of box edges
Mclearance= (Lid) ? 5 : 1;		// clearance between board edge and inside of box
MBez=1;							// This is the thickness covering the non-visible
									// part of the LCD display (MBase thickness - recess)
MLip=20;							// width of lip
MLipThickness=5;

M3clear=3.6/2;

USBclear=2;						// Clearance to leave all around USB connector
ResetHoleSide=2;					// Side of the square reset hole
BuzzerHoleSide=1.5;				// Side of the square buzzer holes

ResetGuideInnerRadius=1.5;
ResetGuideLowerRadius=4.4;
ResetGuideUpperRadius=3.0;

MountHeight=32;					// Height at which to put appjaws1's mount

//************ Leave what follows alone unless you want to change the design ****************

Left=Other43 || Other50 || Other70;		//true if controller board to left of display
Bottom=Itead43 || Itead50;		//true if controller board below the display
Right=false;
SmTol=0.1;						//small tolerence
LidSep=10;						// separation between box and lid
Tol=1;								//main tolerence
ShowPCB=true;
ShowLCD=true;

// LCD display module parameters
// NOTE - use any origin position you want and reference everything to that.
//        I have chosen the bottom left of the LCD screen as the origin, but
//        use anything and the code will sort it out.
LCDscrn =   (Itead43) ? [0,105.6,0,67.8]
			: (Itead50) ? [0,119,0,78.6]
			: (Other43) ? [0,106,0,67.8]
			: (Other50) ? [0,119.5,0,78.5]	// The edges of the whole LCD screen area [Left,Right,Bottom,Top]
			:             [0,165.5,0,101];

LCDview =   (Itead43) ? [3,103,7,64.8]
			: (Itead50) ? [2.5,114.5,3,71.5]
			: (Other43) ? [3,103,7,64.8]
			: (Other50) ? [4.5,118,6,77]		// The edges of the visible region of the LCD screen (L,R,B,T)
			:             [4,158.5,8.5,96];

LCDmounts= (Itead43) ?
			  [
				[2.7,-3.1],
				[102.3,-3.1],
				[2.7,70.9],
				[102.3,70.9]
			  ]
			: (Itead50) ?
			  [
				[1.5,-4.3],
				[116.5,-4.3],
				[1.5,83.2],
				[116.5,83.2]
			  ]
			: (Other43) ? [		// Enter the relative coordinates [X,Y] of each mounting hole
				[-3.5,0],			// You may have as many mounting holes as you like
				[110.5,0],		// Each hole is defined separately for flexibility
				[-3.5,67.8],		// so that holes do not have to be on a rectangular pitch
				[110.5,67.8]		// ... add/remove as needed for modules with more/less mounting holes
			  ]
			: (Other50) ? [
				[-3.75,-0.5],
				[123.75,-0.5],
				[-3.75,78],
				[123.75,78]
			  ]
			:             [
			   [-5,-0.5],
			   [169.5,-0.5],
			   [-5,101.5],
			   [169.5,101.5]
			  ];					

LCDpcb =    (Itead43) ? [-1,106,-6.1,73.6]
			: (Itead50) ? [-1,119.2,-7.8,85.4]
			: (Other43) ? [-7,113,-3.2,71]
			: (Other50) ? [-7,126.5,-3.5,80.5]	// The edges of the LCD PCB [Left,Right,Bottom,Top]
			:             [-8,173,-4,105];

LCDheight = (Itead43) ? 5.3 
			: (Itead50) ? 5.0 
			: (Other43) ? 5.3 
			: (Other50) ? 5.3					// Height of top surface of LCD above PCB (mount standoff height)
			:             7.45;

LCDpin1=	  (Itead43) ? [28.2,-5.0] 
			: (Itead50) ? [35.8,-5.0]
			: (Other43) ? [110.8,10.0]
			: (Other50) ? [124.27,14.37]
			:             [170,26];

LCDmnthole=2.5;					// Hole to take self-tapping screw
LCDbossDia=7;						// Diameter of boss under each mounting hole
LCDbossD2=LCDbossDia*2;			// MBase diameter of boss supports
LCDbossFR=(LCDbossDia-LCDmnthole)/2; // Bottom fillet MMRadius of bosses
LCDsupW=1;						// Width of boss supports

// Controller PCB module parameters
// The 40-pin connector is assumed to be oriented with the long edge in the Y direction.
// Coordinates are from front of PCB.
PCB =[	0,
		(BoardVersion >= 2) ? 67.3 : 47.3,	// version 2 board is actually 65.3, the extra 2mm is to make wiring easier
		0,
		(BoardVersion > 1) ? 73.0 : 69.2
	  ];	// The edges of the controller PCB [Left,Right,Bottom,Top]
PCBmounts=(BoardVersion >= 2)
		 ? [						// Enter the relative coordinates [X,Y] of each mounting hole
			[56.0, 37.8]			// You may have as many mounting holes as you like
			]					
		 : (BoardVersion > 1)
		 ? [						// Enter the relative coordinates [X,Y] of each mounting hole
			[18.1, 16.0],			// You may have as many mounting holes as you like
			[18.1, 54.0]			// Each hole is defined separately for flexibility
			]					
		 : [						// Enter the relative coordinates [X,Y] of each mounting hole
			[18.1, 16.0],			// You may have as many mounting holes as you like
			[44.1, 16.0],			// Each hole is defined separately for flexibility
			[18.1, 54.0]
			];
//PCBshaft=[32.1,16.0];			// XY co-ordinates of rorary encoder shaft on V1.0 board
PCBreset= (BoardVersion >= 2)
			? [57.4,16.5]
			: [21.1,3.7];			// Coordinates of the reset button
PCBerase=	  (BoardVersion >= 2)
			? [53.1,67.5]
			: (BoardVersion > 1)
			? [37.5,22.5]
			: [43.5,26.5];		// Coordinates of the erase button
PCBUSB=	[PCB[1],
			(BoardVersion >= 2) ? 68.05 : 5.6,
			1.2];		// Coordinates of the USB port inc. height from top surface of board
PCBpin1= (BoardVersion >= 2)
			? [46.4,12.5]
			: [10.0,8.4];				// Coordinates of pin 1 of the 40-pin LCD connector
PCBbuzzer=  (BoardVersion >= 2)
			? [57.26,26.52]
			: (BoardVersion > 1)
			? [35.4,50.5]
			: [37.8,50.5];		// Coordinates of buzzer

PCBshaftDia=7;					// Diameter of hole for rotary encoder shaft
PCBheight=13;						// Height controller PCB above LCD standoff
PCBmnthole=2.5;					// Hole to take self-tapping screw
PCBbossDia=7;						// Diameter of boss under each mounting hole
PCBbossD2=PCBbossDia*2;			// MBase diameter of boss supports
PCBbossFR=(PCBbossDia-PCBmnthole)/2; // Bottom fillet MMRadius of bosses
PCBsupW=1;						// Width of boss supports

// Set the size of the enclosure
MLen= (Left) ? LCDpin1[0] - LCDpcb[0] + PCB[1] - PCBpin1[0] + 2*Mclearance
				: LCDpcb[1] - LCDpcb[0] + 2*Mclearance;		// Cavity length
MWid= (Bottom) ? LCDpcb[3] - LCDpin1[1] + PCB[1] - PCBpin1[0] + 2*Mclearance
				: LCDpcb[3] - LCDpcb[2] + 2*Mclearance;		// Cavity width
MHt=PCBheight+LCDheight+MBez+4.5;								// Cavity height
MActualLip = (Lip) ? MLip : 0;

// Set the positions & orientation of LCD and PCB within the enclosure
// NOTE - these are offsets from center of enclosure to origin of LCD
LCDpos=[
			(Left) ? -(LCDpcb[0] + LCDpin1[0] - PCBpin1[0] + PCB[1])/2
					: -(LCDpcb[0] + LCDpcb[1])/2,
			(Bottom) ? -(LCDpcb[3] + LCDpin1[1] + PCBpin1[0] - PCB[1])/2
					: -(LCDpcb[2] + LCDpcb[3])/2
		];		// XY position of LCD visible screen center from case center.

PCBpos=[	LCDpos[0] + LCDpin1[0] - PCBpin1[(Bottom) ? 1 : 0],
			(Bottom) ? LCDpos[1] + LCDpin1[1] + PCBpin1[0] : LCDpos[1] + LCDpin1[1] - PCBpin1[1]
		];					// XY position of controller PCB origin from case center.
PCBrot= (Itead43 || Itead50) ? -90 : 0;	// Degrees to rotate controller PCB within enclosure

USBsize=[9.5,7];					// Length and height of USB connector on PCB

SDsize = [26, 3.6];				// Length and width of the slot for the SD card

// The following defines the position of the slot for the SD card.
// On my 7 inch display it is at the bottom. For the other displays it is at the top.
// This is not supported when using the ITEAD displays.
SDpos = (Other43) ? 	[LCDscrn[0]+40.0,	LCDpcb[3], LCDheight+1.5]
		: (Other50) ? 	[LCDscrn[0]+49.35,	LCDpcb[3], LCDheight+1.5]
		: 					[LCDscrn[0]+2.5,		LCDpcb[2], LCDheight+1.5];

DuetConLen=10;
DuetConWid=6;
Lidmounts=[						// Enter the relative coordinates [X,Y] of each mounting hole
		[(MLen/2)-2,(MWid/2)-2],	// You may have as many mounting holes as you like
		[(MLen/2)-2,-(MWid/2)+2],	// Each hole is defined separately for flexibility
		[-(MLen/2)+2,-(MWid/2)+2],	// so that holes do not have to be on a rectangular pitch
		[-(MLen/2)+2,(MWid/2)-2]	//  add/remove as needed for modules with more/less mounting holes
			 ];						// ...
Lidstandoffheight=MHt;			// Height of top of LCD above PCB (mount standoff height)
Lidmnthole=2;					// Hole to take self-tapping screw
Lidmntclearhole=2.2;			// hole clearence for lid screws
LidbossDia=5;					// Diameter of boss under each mounting hole
LidbossD2=LidbossDia*2;		// MBase diameter of boss supports
LidbossFR=(LidbossDia-Lidmnthole)/2; // Bottom fillet MMRadius of bosses
LidsupW=1;						// Width of boss supports

ResetGuideHeight=LCDheight+PCBheight-6;

overlap=0.1;
$fn=50;  // 50 is good for printing, reduce to render faster while experimenting with parameters


/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

// CODE

mirror([1,0,0])
{
	difference()
	{
		union()
		{
			RoundBox(MLen+2*MWall,MWid+2*MWall,MHt+MBase,MRad,MWall,MBase);
			translate([0,MWid/2,0])
				difference() {
					RoundCube(MLen+2*MWall,2*(MActualLip+MWall),MBase+10,MRad);
					translate([-200,-200,MLipThickness]) cube([400,400,50]);
					translate([-200,-200,-overlap]) cube([400,200,50]);
					translate([-50,10+MWall,-overlap]) cylinder(r=M3clear,h=20);
					translate([50,10+MWall,-overlap]) cylinder(r=M3clear,h=20);
			}
			translate([LCDpos[0],LCDpos[1],0]) LCDmnt();
			translate([PCBpos[0],PCBpos[1],0]) rotate([0,0,PCBrot]) PCBmnt();
		}
		translate([LCDpos[0],LCDpos[1],0]) LCDcutout();
		translate([PCBpos[0],PCBpos[1],0]) rotate([0,0,PCBrot]) USBcutout();
		if (Encoder) {
			translate([PCBpos[0],PCBpos[1],0]) rotate([0,0,PCBrot]) ShaftCutout();
		}
		translate([PCBpos[0],PCBpos[1],0]) rotate([0,0,PCBrot]) ResetCutout();
		translate([PCBpos[0],PCBpos[1],0]) rotate([0,0,PCBrot]) BuzzerHoles();
		if (SD_card) {
			#translate([LCDpos[0]+SDpos[0],LCDpos[1]+SDpos[1]-10,SDpos[2]+MBez])
				cube([SDsize[0], 20, SDsize[1]]);
		}
	}
	if (ShowLCD){
		%translate([LCDpos[0],LCDpos[1],0]) LCDshape();
	}
	if (ShowPCB){
		%translate([PCBpos[0],PCBpos[1],PCBheight+LCDheight+MBez]) rotate([0,0,PCBrot]) PCBshape();
	}
	translate([PCBpos[0],PCBpos[1],0]) rotate([0,0,PCBrot]) ResetGuides();
}

module RoundBox(Len,Wid,Ht,Rad,Wall,Base)
{
	translate([0,0,-Rad*(RelieveOverhang/100)])
	difference()
	{
		RoundCube(Len,Wid,Ht+Rad+Rad*(RelieveOverhang/100)+1,Rad);
		translate([-Len,-Wid,Ht+Rad*(RelieveOverhang/100)])
			cube([2*Len,2*Wid,Rad+2]);
		translate([0,0,Base+Rad*(RelieveOverhang/100)])
			RoundCube(Len-2*Wall,Wid-2*Wall,Ht+Rad+1,Rad-Wall);
		translate([-500,-500,-.1])
			cube([1000,1000,Rad*(RelieveOverhang/100)+.1]);
	}
}

module RoundCube(Len,Wid,Ht,Rad)
{
	translate([-Len/2,-Wid/2+Rad,Rad])
		cube([Len,Wid-2*Rad,Ht-2*Rad]);
	translate([-Len/2+Rad,-Wid/2,Rad])
		cube([Len-2*Rad,Wid,Ht-2*Rad]);
	hull()
	{
		translate([-(Len/2-Rad),-(Wid/2-Rad),Rad]) 	sphere(r=Rad);
		translate([-(Len/2-Rad),+(Wid/2-Rad),Rad]) 	sphere(r=Rad);
		translate([+(Len/2-Rad),-(Wid/2-Rad),Rad]) 	sphere(r=Rad);
		translate([+(Len/2-Rad),+(Wid/2-Rad),Rad]) 	sphere(r=Rad);
		translate([-(Len/2-Rad),-(Wid/2-Rad),Ht-Rad]) sphere(r=Rad);
		translate([-(Len/2-Rad),+(Wid/2-Rad),Ht-Rad]) sphere(r=Rad);
		translate([+(Len/2-Rad),-(Wid/2-Rad),Ht-Rad]) sphere(r=Rad);
		translate([+(Len/2-Rad),+(Wid/2-Rad),Ht-Rad]) sphere(r=Rad);
	}
}

module Lid(){
	difference() {
		union() {
			translate([0,LidSep+MWid,0])RoundBox(MLen+2*MWall,MWid+2*MWall,MBase+2,MRad,MWall,MBase);
			translate([0,LidSep+MWid,overlap])RoundCube(MLen-Tol,MWid-Tol,MBase+4-overlap,0);
		}
		translate([-MLen/2,LidSep+MWid,0]) cube([10,PCB[3]-6,20],center=true);		// cutout for wires
	}
}

module Lidscrewhole(){

	for (Mnt=Lidmounts) {
		translate([Mnt[0],Mnt[1],-2]) cylinder(h=Tol*2+MBase*2,r=Lidmntclearhole);
	}

	for (Mnt=Lidmounts) {
		translate([Mnt[0],Mnt[1],MBase+Tol]) cylinder(h=MWall*2,r=5.5);
	}
}

module Lidmnt()  // This creates the mounts for the Lid
{
	// Make the bosses
	for (Mnt=Lidmounts)
	translate([Mnt[0],Mnt[1],MBase])
	rotate([0,0,45])
	Boss(Lidmnthole,LidbossDia,LidbossD2,MHt,LidsupW);
}

// This creates the mounts for the controller PCB
module PCBmnt()
{
	// Make the bosses
	for (Mnt=PCBmounts) {
		translate([Mnt[0],Mnt[1],MBez])
			rotate([0,0,45])
				Boss(PCBmnthole,PCBbossDia,PCBbossD2,PCBheight+LCDheight,PCBsupW);
	}
}

// This creates the controller PCB shape (as required to help with positioning
module PCBshape()
{
	// Make the PCB
	difference() 	{
		cube([PCB[1]-PCB[0],PCB[3]-PCB[2],1.2]);

//		for (Mnt=PCBmounts) {
//			translate([Mnt[0],Mnt[1],0])
//				Cross(3,100);
//		}
	}
}

// This creates the USB cutout
module USBcutout()
{
	translate([PCBUSB[0]+Mclearance+(MWall/2),PCBUSB[1],PCBheight+LCDheight+MBez-PCBUSB[2]])
		cube([MWall+2*overlap,USBsize[0]+2*USBclear,USBsize[1]+2*USBclear], center=true);
}

// This creates the shaft cutout
module ShaftCutout()
{
	translate([PCBshaft[0],PCBshaft[1],-overlap]) cylinder(r=PCBshaftDia/2,h=MBase+2*overlap);
}

module ResetCutout()
{
	translate([PCBreset[0],PCBreset[1],0]) cube([ResetHoleSide,ResetHoleSide,2*(MBase+overlap)],center=true);
	translate([PCBerase[0],PCBerase[1],0]) cube([ResetHoleSide,ResetHoleSide,2*(MBase+overlap)],center=true);
}

// This creates the shaft cutout
module BuzzerHoles()
{
	translate([PCBbuzzer[0],PCBbuzzer[1],0]) {
		for(n=[0:3]) {
			rotate([0,0,90*n])
				translate([2.5,0,0])
					cube([BuzzerHoleSide,BuzzerHoleSide,2*(MBase+overlap)], center=true);

		}
	}
}

module ResetGuides()
{
	translate([PCBreset[0],PCBreset[1],MBase - overlap])
		difference() {
			cylinder(r1=ResetGuideLowerRadius, r2=ResetGuideUpperRadius, h=ResetGuideHeight+overlap);
			translate([0,0,-overlap]) cylinder(r=ResetGuideInnerRadius, h=ResetGuideHeight+3*overlap);
		}
	translate([PCBerase[0],PCBerase[1],MBase - overlap])
		difference() {
			cylinder(r=ResetGuideLowerRadius, r2=ResetGuideUpperRadius, h=ResetGuideHeight+overlap);
			translate([0,0,-overlap]) cylinder(r=ResetGuideInnerRadius, h=ResetGuideHeight+3*overlap);
		}
}

// This creates the mounts for the LCD
module LCDmnt()
{
		// Make the bosses
		for (Mnt=LCDmounts) {
			translate([Mnt[0],Mnt[1],MBez])
				rotate([0,0,45])
					Boss(LCDmnthole,LCDbossDia,LCDbossD2,LCDheight,LCDsupW);
		}
}

// This creates the LCD PCB and screen shapes (as required to help with positioning)
module LCDshape()
{
	difference() {
		union() {
			translate([LCDpcb[0],LCDpcb[2],MBez+LCDheight])
				cube([LCDpcb[1]-LCDpcb[0],LCDpcb[3]-LCDpcb[2],1.5]);
			translate([LCDscrn[0],LCDscrn[2],MBez])
				cube([LCDscrn[1]-LCDscrn[0],LCDscrn[3]-LCDscrn[2],LCDheight]);
		}
//		for (Mnt=LCDmounts) {
//			translate([Mnt[0],Mnt[1],0])
//				Cross(3,100);
//		}
	}
}
// This creates the case cutout for the LCD display
module LCDcutout()
{
	translate([LCDscrn[0],LCDscrn[2],MBez])
	cube([LCDscrn[1]-LCDscrn[0],LCDscrn[3]-LCDscrn[2],100]);
	translate([LCDview[0],LCDview[2],-.1])
	cube([LCDview[1]-LCDview[0],LCDview[3]-LCDview[2],100]);
}

module Boss(HoleD,Dia1,Dia2,Ht,MWall)
{
	difference()
	{
		union()
		{
			cylinder (r=Dia1/2,h=Ht);
			Xsupport(Dia1,Dia2,Ht,MWall);
			CirFillet(Dia1,MWall);
		}
		translate([0,0,-.1]) cylinder(r=HoleD/2,h=Ht+.2);
	}
}

module Xsupport(Dia1,Dia2,Ht,MWall)
{
	difference()
	{
		union()
		{
			translate([-Dia2/2,-MWall/2,0]) cube([Dia2,MWall,Ht]);
			translate([-MWall/2,-Dia2/2,0]) cube([MWall,Dia2,Ht]);
		}
		difference()
		{
			translate([0,0,-1])
			cylinder(r=Dia2,h=Ht+2);
			cylinder(r1=Dia2/2,r2=Dia1/2,h=Ht+.1);
		}
	}
}

module CirFillet(D,R)
{
	difference()
	{
		rotate_extrude() translate([D/2,0,0]) square(R);
		rotate_extrude() translate([D/2+R,R,0]) circle(r=R);
	}
}

// Draws a negative crosshair		
module Cross(R,H)
{
	rotate([0,0,0]) Quad(R,H);
	rotate([0,0,90]) Quad(R,H);
	rotate([0,0,180]) Quad(R,H);
	rotate([0,0,270]) Quad(R,H);
}

module Quad(R,H)
{
	difference()
	{
		cylinder(r=R,h=H);
		translate([-500,-500,-.1]) cube([500.1,1000,H+.2]);
		translate([-500,-500,-.1]) 	cube([1000,500.1,H+.2]);
	}
}

module Box(){
	// RoundBox(MLen+2*MWall,MWid+2*MWall,MHt+MBase,MRad,MWall,MBase);
	 if(Lid){  
		if (screw){ 
			Lidmnt();
			if (Right){
				difference(){ 
					Lid();
					translate([0,10+MWid,1])Lidscrewhole();
				}
			}
			else {
				translate ([0,(-LidSep-MWid)*2,0])
					difference(){ 
						Lid();
						translate([0,10+MWid,1])Lidscrewhole();
					}
			}
				//else {Lid();}
		}
	}
}

Box();

/*
if (Mount) {
	if(Right){ 
		translate([0,-MountHeight-MWid/2,(MHt/2)+Tol*2])
			rotate([90,90,0])
				import("appjaws-LCD-box-mount.stl");
	}
	else {
		translate([0,MountHeight+MWid/2,(MHt/2)+Tol*2])
			rotate([90,90,180])
				import("appjaws-LCD-box-mount.stl");
	}
}
*/
