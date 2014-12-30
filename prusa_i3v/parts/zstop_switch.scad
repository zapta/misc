// Makefarm Prusa i3v screw adjusted Z stop.
// Part 1 of 2: the switch bracket.

// Set to 0 for final STL compilation (slow). Set to 1 for quick
// debugging (lower quality)
debug = 0;

// Determine the quality of circles (better = slower compilation).
$fn = (debug != 0) ? 12 : 72;

// Define of the main sub part
body_width = 13.7; 
body_length = 48; 
body_height = 18; 

// Define of the V slot.
slot_width = 10;  // at wide side (was 9)
slot_thickness = 2;
slot_angle = 45;
slot_margin = 5;

// Define of the M5 screw hole.
slot_hole_offset = slot_width/2 + slot_margin;
slot_hole_height = body_height / 2;
slot_hole_diameter = 5.2;  // slight margin for M4 screw.

// Defines of the M5 screw head sink.
slot_hole_sink_thickness = 6.5;
slot_hole_sink_diameter = 12;

// Define the two M3 switch holes.
switch_center_offset = slot_hole_offset + 26;
switch_holes_spacing = 10;
switch_holes_height = 14;
switch_holes_diameter = 2.9;  // M3 screws thread into this hole.

// Define the substraction below the switch.
notch_height = 7;
notch_length = body_length - 2*slot_margin - slot_width;

// Defines the diagonal cut at the end left end.
chop_radius = 4;

// Small >0 dimension to disambigue operations.
eps = 0.001;
eps2 = 2*eps;

// Creates the trapezoide that fits the V slot.
module slot() {
  inset = slot_thickness / tan(slot_angle);

  translate([body_length - slot_hole_offset - slot_width/2, body_width - eps, 0]) 
  linear_extrude(height=body_height)
      polygon(points=[[0,0],[inset, slot_thickness + eps],[slot_width-inset, slot_thickness + eps],[slot_width,0]]);


//    translate([body_length - slot_hole_offset - slot_width/2, body_width - eps, 0]) 
//          slot(body_height, slot_width, slot_thickness + eps, 45);

}

// Creates a hole cylinder at given radius and depth from the front face.
module hole(x, z, l, r) {
  translate([x, -eps, z]) rotate([-90, 0, 0])  cylinder(r=r, h=l+eps2);
}

// Creates the main body, before adding the vslot and substracting the
// holes and notch.
module body() {
  cube([body_length, body_width, body_height]);
}

module slot_hole() {
  // M5 screw hole
  hole(body_length - slot_hole_offset, slot_hole_height, body_width+slot_thickness, slot_hole_diameter/2);
  // Screw head sink hole
  hole(body_length - slot_hole_offset, slot_hole_height, body_width-slot_hole_sink_thickness, slot_hole_sink_diameter/2);
}

module switch_holes() {
 // M3 switch hole 1.
    hole(body_length - switch_center_offset + switch_holes_spacing/2 , switch_holes_height, body_width, switch_holes_diameter/2);
    // M3 switch hole 2.
    hole(body_length - switch_center_offset - switch_holes_spacing/2, switch_holes_height, body_width, switch_holes_diameter/2);
}

module cuts() {
  translate([-eps, -eps, 0]) cube([notch_length+eps, body_width+eps2, notch_height]);
 // cube([2*body_width, body_width, body_height+eps]);
  translate([0, body_width - chop_radius, 0]) rotate([0, 0, 45]) cube([2*body_width, body_width, body_height+eps]);
}

// Creates the entire part.
module main() {
  difference() {
    union() {
      body();
      slot();
      //translate([body_length - slot_hole_offset - slot_width/2, body_width - eps, 0]) 
      //    slot(body_height, slot_width, slot_thickness + eps, 45);

    }
    slot_hole();
    switch_holes();
    cuts();

    // M5 hole
    // hole(body_length - slot_hole_offset, slot_hole_height, body_width+slot_thickness, slot_hole_diameter/2);
    // M5 screw head sink hole
    //hole(body_length - slot_hole_offset, slot_hole_height, body_width-slot_hole_sink_thickness, slot_hole_sink_diameter/2);
    // M3 switch hole 1.
    //hole(body_length - switch_center_offset + switch_holes_spacing/2 , switch_holes_height, body_width, switch_holes_diameter/2);
    // M3 switch hole 2.
    //hole(body_length - switch_center_offset - switch_holes_spacing/2, switch_holes_height, body_width, switch_holes_diameter/2);
    // Notch removal.
    //translate([-eps, -eps, 0]) cube([notch_length+eps, body_width+eps2, notch_height]);
  }
}

 // translate([0, body_width-5, 0]) rotate([0, 0, 45]) cube([2*body_width, body_width, body_height+eps]);

if (debug != 0) {
  // Part is in it's natural orientation.
  main();
  // A simple reminder that we are in the debug mode.
  sphere(r=1, center=true);
} else {
  // Part is in it's printing orientation.
  rotate([90, 0, 0]) main();
}
