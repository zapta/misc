// Makefarm Prusa i3v screw adjusted Z stop.
// Part 2 of 2: the screw holder.

// Set to 0 for final STL compilation (slow). Set to 1 for quick
// debugging (lower quality)
debug = 0;

// Determine the quality of circles (better = slower compilation).
$fn = (debug != 0) ? 12 : 72;

// Defines of the main block, without the slot and the holes.
body_width = 18; 
body_length = 40; 
body_height = 10; 
body_corner_radius = 2;

// Definse of the V slot.
slot_width = 10;
slot_height = 2;
slot_angle = 45;
slot_margin = 0;

// Defines of the M5 screw hole.
slot_hole_offset_from_edge = 18;
slot_hole_diameter = 5.2; 

// Defines of the M5 screw head sink hole.
slot_hole_sink_thickness = 6.5;  // distance from aluminum rail surface.
slot_hole_sink_diameter = 12;

// Defines the M3 adjustment screw hole
screw_hole_offset_from_edge = 5;
screw_hole_diameter = 2.7;  

// Small >0 dimension to disambigue operations.
eps = 0.001;
eps2 = 2*eps;

// Generic cube with for corners rounded.
module rounded_cube(xlen, ylen, zlen, r) {
  translate([r, r, 0]) minkowski() {
    cube([xlen-2*r, ylen-2*r, zlen/2]);
    cylinder(r=r, h=zlen/2);
 }
}

// The main block of the part, without the slot and holes.
module body() {
  rounded_cube(body_length, body_width, body_height, body_corner_radius);
}

// Generic vertical hole.
module hole(x, y, h, r) {
  translate([x, y, -eps]) cylinder(r=r, h=h+eps2);
}

// The V slot.
module slot() {
  inset = slot_height / tan(slot_angle);
  translate([0, (body_width- slot_width)/2, body_height - eps]) 
  rotate([90, 0, 90])
  linear_extrude(height=body_length - slot_margin)
      polygon(points=[[0,0],[inset, slot_height + eps],
         [slot_width-inset, slot_height + eps],[slot_width,0]]);
}


// The M5 hole and screw head sink.
module slot_hole() {
  hole_x = body_length - slot_hole_offset_from_edge;
  hole_y = body_width/2;
  hole(hole_x, hole_y, body_height+slot_height, slot_hole_diameter/2);
  hole(hole_x, hole_y, body_height - slot_hole_sink_thickness, slot_hole_sink_diameter/2);
}

// The M3 screw hole.
module screw_hole() {
    hole(body_length - slot_margin - screw_hole_offset_from_edge,
         body_width/2, body_height + slot_height, screw_hole_diameter/2);
}

// The entire part.
module main() {
  difference() {
    union() {
      body();
      slot();
    }
    slot_hole();
    screw_hole();
  }
}

main();
