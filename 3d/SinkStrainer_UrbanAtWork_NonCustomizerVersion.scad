// Sink Strainer - Drain Catch 
// By Urban Reininger   2015-06-15
// Twitter: UrbanAtWork
// Thingiverse: http://www.thingiverse.com/UrbanAtWork/
//
// Original by Thingiverse user: HarlanDMii

// IF THIS IS RENDERING SLOW .... then lower the $fn values to your liking.


//Drain Diameter (bathtub 38, bathroom sink 28.5)
diameter=38; //

// I don't think this scaling works properly for Thingiverse Customizer... will rework if time allows
scale(diameter/36.25,[1,1,1]) //bathtub 38


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
		color ("silver") cylinder(r1=18.5,r2=19.5,h=1.5,$fn=100); // Urban moved this too  
	}
	color ("plum") cylinder(r=3.5,h=10,center=true,$fn=60);	 // Center hole
}

// Helper Disk 0.2mm for 
	color ("green") cylinder(r=diameter/2.3,h=0.02,center=true,$fn=60);