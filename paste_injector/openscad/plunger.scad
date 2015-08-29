// Threaded plunger for 10cc syringe.
//
// Includes an embeded M5 nut. To embed the nut, set the 3D slicer
// to stop just before the first layer on top of the nut, insert
// the nut, and continue the printing.

// Circle reslolution. Higher is smoother.
$fn=180;

// Section 1 - away from the syringe tip.
od1 = 15.1;  
h1 = 37.5;

// Section 2 - middle.
od2 = 8;
h2 = 1;

// Section 3 - toward the syringe tip. Dimension set to
// fit into the syringe rubber cylinder.
od3 = 12.8;
h3 = 1.5;

// Total plunger height.
total_height = h1 + h2 + h3;
echo("*** total height: ", total_height);

// Standard chamfer size.
chamfer = 0.5;

// Shaft hole length.
screw_hole_len = total_height - 4;
screw_hole_diameter = 6;

// For M4 hex nut. Diameter is between oposing corners.
// Use trial and error to get good fit with your printer's tolerances.
//nut_thickness = 3.3;
//nut_diameter = 8.5;
//nut_offset_from_edge = 2;

// Very small sizes. Used to maintain manifold.
eps1 = 0.001;
eps2 = 2*eps1;

// Hole for a M4 metal insert, mcmaster part number 94180A353.
// h is the total depth for the screw hole.
module m4_threaded_insert(d, h) {
  // Adding tweaks for compensate for my printer's tolerace.
  A = 5.3 + 0.3;
  B = 5.94 + 0.4;
  L = 7.9;
  translate([0, 0, -eps1]) {
    // NOTE: diameter are compensated to actual print results. 
    // May vary among printers.
    cylinder(d1=B, d2=A, h=eps1+L*2/3); 
    cylinder(d=A, h=eps1+L);
    translate([0, 0, L-eps1]) cylinder(d=d, h=h+eps1-L);
  }
}

// c1, c2 are chamfers at bottom and top respectivly. s1, s2 are chamfers's slopes.
module chamfered_cylinder(d, h, c1, s1, c2, s2) {
    cylinder(d1=d-2*c1, d2=d, h=s1*c1);
    translate([0, 0, s1*c1-eps1]) cylinder(d=d, h=h-s1*c1-s2*c2+eps2);
    translate([0, 0, h-s2*c2]) cylinder(d1=d, d2=d-2*c2, h=s2*c2);
}

module body() {
  chamfered_cylinder(od1, h1, 2*chamfer, 1, (od1-od2)/2, 2);  
  translate([0, 0, h1-eps1]) cylinder(d=od2, h=h2+eps1);  
  translate([0, 0, h1+h2-eps1]) chamfered_cylinder(od3, h3, chamfer/2, 1, chamfer/2, 1);
}

module main() {
  difference() {
    body();
    m4_threaded_insert(screw_hole_diameter, screw_hole_len);
  }
}

// Cross cut for debugging.
difference() {
  main();
  translate([0, 0, -eps1]) cube([100, 100, 100]);
}

// The real part oriented for printing.
//translate([0, 0, total_height]) rotate([180, 0, 0]) main();

//difference() {
//translate([0, 0, total_height]) rotate([180, 0, 0]) main();
//  translate([0, 0, 12])cylinder(d=30, h=total_height-24);
//}







