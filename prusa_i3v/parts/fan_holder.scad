// Workpiece cooling fan holder for Makerfarm Prusa i3v.

// Set to 0 for final STL compilation (slow). Set to 1 for quick
// debugging (lower quality)
debug = 0;

// Set the mode (must be set to 0 for real STL generation).
$fn = (debug != 0) ? 16 : 180;

// Define the main block, without the slot and the holes.
base_length = 60; 
base_top_thickness = 3; 
base_side_thickness = 16;
base_width = base_side_thickness + 6;
base_height = base_top_thickness + 10;

// Define the hole that used to secure the holder to the extruder. 
// This is a M3x20 screw that replcaes the stock M3x16 on the left
// side of the extruder's base.
base_hole_diameter = 3.3;
// Distnace from the top of the part to the center of the hole.
base_hole_vertical_offset = base_top_thickness + 3;
base_hole_horizontal_offset = 43;
// Make the hole a vertical slot to allow this amount of play in 
// each direction.
base_hole_vertical_play = 1;
// Fan angle. 0 is vertical. 
base_slop_angle = 45;
// The thickness left for the thread after removing the screw head sink.
// 4mm allows to go from the stock M3x16 to M3x20.
base_sink_thickness = 4;
// Have sufficient clearance for the M3 head.
base_sink_diameter=9;

// Define the two fan screw holes. The holes are perpendicular
// to the surface of the slope.
fan_screw_hole_diameter = 2.5;
fan_screw_hole_space = 32;
fan_screw_hole_slope_offset = 4;
fan_screw_hole_horizontal_offset = 3.5;

// Define the big cut for the air flow. This cut is 
// perpendicular to the slope surface.
fan_vent_diameter = 35;

// Small > 0 values that are used to maintain manifold.
eps=0.001;
eps2 = 2 * eps;

// The main block, with a cut to form a L shape profile.
module base_main() {
  difference() {
    cube([base_width, base_length, base_height]);
    translate([base_side_thickness, -eps, -base_top_thickness]) 
        cube([base_width+eps, base_length+eps2, base_height+eps]); 
  }
}

module horizontal_hole(y, z, depth, d) {
  translate([-eps, y, z]) rotate([0, 90, 0]) 
    cylinder(r=d/2, h=depth + eps2);
}

// The hole and sink for the base screw.
module base_hole() {
  y = base_hole_horizontal_offset;
  z = base_height - base_hole_vertical_offset;
  // Vertical slot for perfect fit.
  hull() {
    horizontal_hole(y, z+base_hole_vertical_play, base_width, base_hole_diameter);
    horizontal_hole(y, z-base_hole_vertical_play, base_width, base_hole_diameter);
  }
  hull() {
    horizontal_hole(y, z+base_hole_vertical_play, base_side_thickness - base_sink_thickness, base_sink_diameter);
    horizontal_hole(y, z-base_hole_vertical_play, base_side_thickness - base_sink_thickness, base_sink_diameter);
  }
}

// A general round hole that is perpendicular to the slop surface. Offset is from
// the top of the slop, d diameter.
module slope_hole(y, offset, d) {
  // Some math mumbo jumbo.
  t1 = offset * cos(base_slop_angle);
  t2 = base_height - t1;
  t3 = tan(base_slop_angle)*t2;
  t4 = t3 * tan(base_slop_angle);
  z = t2 + t4;
  translate([-eps, y, z]) rotate([0, 90+base_slop_angle, 0])  
      translate([0, 0, -base_width]) cylinder(r=d/2, h=2*base_width);
}

module fan_screw_holes() {
  slope_hole(fan_screw_hole_horizontal_offset, fan_screw_hole_slope_offset, fan_screw_hole_diameter);
  slope_hole(fan_screw_hole_horizontal_offset + fan_screw_hole_space, 
      fan_screw_hole_slope_offset, fan_screw_hole_diameter);
}

module fan_vent() {
   y = fan_screw_hole_horizontal_offset + fan_screw_hole_space/2;
   slope_hole(
      fan_screw_hole_horizontal_offset + fan_screw_hole_space/2, 
      fan_screw_hole_slope_offset + fan_screw_hole_space/2, 
      fan_vent_diameter);
}

// Defines a substruction from the main body that creates the slope.
module slop() {
  rotate([0, base_slop_angle, 0]) translate([-base_width, -eps, 0]) 
      cube([base_width, base_length+eps2, 2*base_height]);
}


// The entire part.
module main() {
  difference() {
    base_main();
    // Reovals.
    base_hole();
    fan_screw_holes();
    fan_vent();
    slop();
  }
}

if (debug != 0) {
  // Debug in normal orientation.
  main();
} else {
  // Orientation for printing. 
  rotate([0, -90 - base_slop_angle, 0]) main();
}
