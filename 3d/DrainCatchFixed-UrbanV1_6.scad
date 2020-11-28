// By Urban Reininger   2015-06-15
// Twitter: UrbanAtWork
// Thingiverse: http://www.thingiverse.com/UrbanAtWork/
//
// Original by Thingiverse user: HarlanDMii

// I am currently editing this document so if it doesn't work that is why... (Monday Afternoon)
Notice="This files is being worked on";
//Drain Diameter (bathtub 38, bathroom sink 28.5) - I don't think this works right...
diameter=38; //

scale(diameter/36.25,[1,1,1]); //bathtub 38

// Add a Helper Disk for good plate adhesion (0.02 layer height)

// A 0.2mm helper disk will be added to the bottom to help plate adhesion. It's easy to break off. 
HelperDisk = "yes"; // [yes,no]

//_______________________________________
// original design=36.25mm
// To calculate the scale..
// NewScale=DiameterRequired/36.25
//_______________________________________


difference(){	
	union(){   // main drain basket
		intersection(){
		color ("green") cylinder(r1=35/2,r2=37/2,h=10,$fn=100);
		translate([0,0,12])
		color ("lime") sphere(19,$fn=100);
		}
		translate([0,0,10])
		cylinder(r1=37/2,r2=39/2,h=1.5,$fn=100);	
	}
        
        
	translate([0,0,20])
	color ("orange") sphere(35.5/2,$fn=200);
	//translate([0,0,3])
	//color ("gold") cylinder(r=34.5/2,h=11,$fn=25);
	
	//r=25;
        
       difference(){                            // Urban Moved this outside of the for loop
	for (r=[0:40:359]){
		rotate(r)
	hull(){
           		translate([5,0,-8])
			rotate([0,90,0])
			cylinder(r1=.9,r2=3.75,h=28/2,$fn=45);
			translate([5,0,5])
			rotate([0,90,0])
			cylinder(r1=.9,r2=6.75,h=28/2,$fn=45);
		}

	}
                translate([0,0,10])                                       //Urban moved 
		color ("silver") cylinder(r1=18.5,r2=19.5,h=1.5,$fn=45); // Urban moved this too  
	}
	color ("plum") cylinder(r=3.5,h=10,center=true,$fn=9);	 // Center hole
}

  if(HelperDisk=="yes"){
	color ("green") cylinder(r=diameter/2.3,h=0.02,center=true,$fn=60);	 // Helper Disk on Bottom for easier printing adhesion.
    }