// Extruder tool for Makerfarm i3v.

// Set to 0 for final STL compilation (slow). Set to 1 for quick
// debugging (lower quality)

/* [Hidden] */

debug = 0;

// Determine the quality of circles (better = slower compilation).
$fn = (debug != 0) ? 12 : 72;

/* [Global] */

// Controls the opening of the extruder.
body_thickness = 5; // [3:8]
// Width.
body_width = 11;   // [5:15]
// Lengnth.
body_length = 30;  // [10:50]
// Size of the stopper.
step_height = 4.5; // [0:6]
// Controls the insertion depth.
step_offset = 7.5;  // [0:15]
// Hole diameter.
hole_diameter = 4;  // [0:8]
// Hole distance from the edge.
hole_offset = 5;  // [0:15]
// Corner rounding radius
body_corner_radius = 2;  // [0:10]

/* [Hidden] */

step_top_length = 2;
step_angle = 45;

// Small >0 dimension to maintain manifold.
eps = 0.001;
eps2 = 2*eps;

// Generic cube with for corners rounded.
module rounded_cube(xlen, ylen, zlen, r) {
  translate([r, r, 0]) minkowski() {
    cube([xlen-2*r, ylen-2*r, zlen/2]);
    cylinder(r=r, h=zlen/2);
 }
}

// The main block.
module body() {
  rounded_cube(body_length, body_width, body_thickness, body_corner_radius);
}

module hole() {
  translate([body_length - hole_offset, body_width/2, -eps]) 
    cylinder(r=hole_diameter/2, h= body_thickness+eps2);
}

// The step above the body.
module step() {
  step_base_length = step_top_length + (step_height / tan(step_angle));
  translate([step_offset, body_width, body_thickness - eps]) 
  rotate([90, 0, 0]) linear_extrude(height=body_width)
      polygon(points=[
          [0,0], 
          [0, step_height], 
          [step_top_length, step_height], 
          [step_top_length + step_base_length, 0]]);
}

// The entire part.
module main() {
  difference() {
    union() {
      body();
      step();
    }
    hole();
  }
}

main();
