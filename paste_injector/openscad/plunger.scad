// Threaded plunger for 10cc syringe. Using McMaster 94180A353 M4 threaded
// insert (use any conic solder iron to insert after printing). The conic tip
// should be placed between the plunger and the rubber cylinder to displace
// the air pocket.

// Circle reslolution. Higher is smoother.
$fn=180;

// Section 1 - away from the syringe tip.
od1 = 13;  
h1 = 42.8;

// Section 2 - middle.
od2 = 8.5;
h2 = 1.0;

// Section 3 - toward the syringe tip. Dimension set to
// fit into the syringe rubber cylinder.
od3 = 12.5;
h3 = 1.2;

// Total plunger height.
total_height = h1 + h2 + h3;
echo("*** total height: ", total_height);

// Standard chamfer size.
chamfer = 0.5;

// Shaft hole length.
screw_hole_len = total_height - 2;
screw_hole_diameter = 6;

tip_cone_height = 1.4;
tip_top_diameter = 5;
tip_base_height = 0.4;
tip_base_diameter = od3;

// Very small sizes. Used to maintain manifold.
eps1 = 0.001;
eps2 = 2*eps1;

// c1, c2 are chamfers at bottom and top respectivly. s1, s2 are chamfers's slopes.
module chamfered_cylinder(d, h, c1, s1, c2, s2) {
    cylinder(d1=d-2*c1, d2=d, h=s1*c1);
    translate([0, 0, s1*c1-eps1]) cylinder(d=d, h=h-s1*c1-s2*c2+eps2);
    translate([0, 0, h-s2*c2]) cylinder(d1=d, d2=d-2*c2, h=s2*c2);
}

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
    translate([0, 0, L-eps1]) chamfered_cylinder(d, h+eps2-L, eps1, 1,   1.5*chamfer, 1);
  }
}

module body() {
  // NOTE: using 6.0 chamfer slop to improve printing.
  chamfered_cylinder(od1, h1, 2*chamfer, 1, (od1-od2)/2, 6.0);  
  translate([0, 0, h1-eps1]) cylinder(d=od2, h=h2+eps1);  
  translate([0, 0, h1+h2-eps1]) chamfered_cylinder(od3, h3, chamfer/2, 1.0, chamfer/2, 1.0);
}

module tip() {
  chamfered_cylinder(tip_base_diameter, tip_base_height+eps1, 0.2, 1.0, eps1, 1.0);
  translate([0, 0, tip_base_height]) 
    cylinder(d1=tip_base_diameter, d2=tip_top_diameter, h=tip_cone_height); 
}

module plunger() {
  difference() {
    body();
    m4_threaded_insert(screw_hole_diameter, screw_hole_len);
  }
}

// The plunger and tip, oriented for printing.
module main() {
  translate([0, 0, total_height]) rotate([180, 0, 0]) plunger();;
  translate([2*od1, 0, 0]) tip();
}

// Plunger cross cut for debugging. Do not print.
module crossCut() {
   translate([-2*od1, 0, total_height]) rotate([180, 0, 0]) {
    difference() {
      plunger();
      translate([0, 0, -eps1]) cube([100, 100, 100]);
    }
  }
}

main();

// For debugging.
//crossCut();







