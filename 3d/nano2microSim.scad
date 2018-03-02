///////////////////
// nano to micro sim adapter (e.g. iPhone 5 to iPhone 4)
// P. Mikulastik
// patrick@mikulastik.de
// 04/2013

padding = 0.2; // padding around hole for nano sim, to make it fit nicely

linear_extrude(height=0.67) // taken from off. specs
difference() {
	// micro sim
	polygon( [ [0,0],[12.5,0],[15,2.5],[15,12],[0,12] ], [ [0,1,2,3,4] ]); // taken from off. specs

	// nano sim
	translate([1.15,2.4,0]) // don't know if these settings are correct, but they work
	minkowski() {
		polygon( [ [0,0],[10.65,0],[12.3,1.65],[12.3,8.8],[0,8.8] ], [ [0,1,2,3,4] ]); // taken from off. specs
		circle(r=padding);
	}
}


