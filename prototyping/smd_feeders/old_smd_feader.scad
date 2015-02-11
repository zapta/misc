// TODO: cleanup.

/* [Global] */

// Overall length.
total_length = 23;  

// Thickness of side walls.
side_wall_width = 1.5;

// Thickness of the bottom.
bottom_thickness = 1; 
// Thickness of the top.
top_thickness = 1;

// Length of the part picking hole.
top_hole_length = 10;
// Offset of the part picking hole from the part's end.
top_hole_offset = 2;

// Width of the tape slot (tape width + margin).
tape_slot_width = 8.5;
// Height of the tape slot (tape thickness + margin)
tape_slot_height = 1.3;

// Width of the slot below the tape.
part_slot_width = 6;
// Height of the slot below the tape.
part_slot_height = 2;
// Taper angle at the tape entry and exit ends.
part_slot_taper_angle = 25;

// Height below the tape peeling bridge.
bridge_gap = 1.5;
// Width of the tape peeling bridge.
bridge_width = 3;
// Thickness of the tape peeling bridge top.
bridge_top_thickness = 1;

bridge_height = bridge_gap + bridge_top_thickness;

// Width of the tape peeling ramp. 
ramp_width = 6;
// Height of the tape peeling ramp.
ramp_height = 4;
// Horizontal length of the tape peeling ramp.
ramp_length = 5;
// Extra length at the high end of the ramp.
ramp_tail_length = 2;
// Ramp offset from the part end.
ramp_offset = 16;
// Thickness of the plate that connects feeders.
plate_thickness = 1;
// Number of feeders.
array_size = 5;
// Spacing between feeders.
inter_unit_space = 7;

/* [Hidden] */

base_length = total_length;
base_height = bottom_thickness + part_slot_height + tape_slot_height;
base_width = tape_slot_width + 2*side_wall_width;

eps1 = 0.001;
eps2 = 2*eps1;

module tape_slot_taper(x, y, a) {
  translate([x, y, 0])
  rotate([0, 0, a])
  translate([-3*side_wall_width/2, 0, 0])  cube([3*side_wall_width, eps1, tape_slot_height+eps2]);
}

module base_body() {
  cube([base_length, base_width, base_height]);
}

module parts_slot() {
 translate([-eps1, (base_width-part_slot_width)/2, 0]) 
    cube([base_length+eps2, part_slot_width, part_slot_height]);  
}

module tape_slot() {
 a = part_slot_taper_angle;
 translate([-eps1, (base_width-tape_slot_width)/2, 0]) cube([base_length+eps2, tape_slot_width, tape_slot_height+eps2]);

 hull() {
  tape_slot_taper(0,  side_wall_width/2, a);
  tape_slot_taper(0, base_width - side_wall_width/2, -a);
 }

 hull() {
 tape_slot_taper(total_length, side_wall_width/2, -a);
 tape_slot_taper(total_length, base_width - side_wall_width/2, a);
 }
}


module base_main() {
  difference() {
    base_body();
    translate([0, 0, bottom_thickness]) parts_slot();
    translate([0, 0, bottom_thickness+part_slot_height-eps1]) tape_slot();
  }
}

module top_ramp() {
  translate([0, (base_width-ramp_width)/2, 0]) hull() {
    cube([eps1, ramp_width, eps1]);
    translate([ramp_length, 0, 0])  cube([eps1, ramp_width, ramp_height]);
    translate([ramp_length+ramp_tail_length, 0, 0])  cube([eps1, ramp_width, ramp_height]);

  }
}

module top_hole(x, l, w) {
  translate([x, (base_width-w)/2, -eps1]) cube([l, w, top_thickness + eps2]);
}

module bridge_main() {
  difference() {
    cube([bridge_width, base_width, bridge_gap + bridge_top_thickness]);
    translate([-eps1, (base_width - tape_slot_width)/2, -eps1]) cube([bridge_width+eps2, tape_slot_width, bridge_gap+eps1]);
}
}

module top_main() {
  difference() {
  cube([base_length, base_width, top_thickness]);
  top_hole(top_hole_offset, top_hole_length, tape_slot_width);
}
  translate([ramp_offset, 0, top_thickness - eps1]) top_ramp();
}

// For printing without material support. Requires gluing of the three parts.
module disassembled_unit() {
  base_main();
  translate([0, -base_width * 1.2, 0]) top_main(); 
  translate([-4, 0, bridge_height]) rotate([0, 180, 0]) bridge_main();
}

module assembled_unit() {
   base_main();
   translate([0, 0, base_height-eps1]) top_main();
   translate([bridge_width + 10, 0,  base_height + top_thickness - eps2]) bridge_main();
}

module assembled_array() {
  width = array_size*base_width + (array_size-1)*inter_unit_space; 
  for ( i = [0 : array_size-1] ) {
    translate([0, i*(base_width + inter_unit_space), plate_thickness - eps1]) assembled_unit();
  }
  cube([base_length, width, plate_thickness]);
}

assembled_array();






