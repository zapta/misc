// Manual SMT cut strip feeder array.

// TODO: cleanup.

/* [Hidden] */
eps1 = 0.0001;
eps2 = 2*eps1;

/* [Setting] */

// Number of feeders.
feeders_count = 2;

// Width of the tape slot (tape width + margin).
tape_slot_width = 9;

// Height of the tape slot (tape thickness + margin)
tape_slot_height = 1.5;

// The width of the tight (viewed from front) tape slot support.
tape_support_width_right = 1.5;

// The width of the left (viewed from front) tape slot support.
tape_support_width_left = 2.5;

// Width of the slot below the tape.
part_slot_width = tape_slot_width - tape_support_width_left - tape_support_width_right ;

// Height of the slot below the tape. Set to 0 for none.
part_slot_height = 0;

// Overall length.
total_length = 20;  

// Spacing between feeders.
inter_feeder_space = 5;

/* [Tweaking] */

// Thickness of side walls.
side_wall_width = 1;

// Thickness of the bottom.
bottom_thickness = 1; 

// Thickness of the top.
top_thickness = 1;


// Taper angle at the tape entry and exit ends.
tape_slot_taper_angle = 45;

// Height below the tape peeling bridge.
bridge_gap = 1;

// Width of the tape peeling bridge, viewing from the side.
bridge_width = 2;

// Thickness of the tape peeling bridge top.
bridge_top_thickness = 1;

// Distance of the peeling bridge from the front of the part.
bridge_offset = 0;

// Total bridge height.
bridge_height = bridge_gap + bridge_top_thickness;

// Height of the tape peeling ramp.
ramp_height = 3;

// Horizontal length of the tape peeling ramp.
ramp_length = 3;

// Extra length at the high end of the ramp.
//ramp_tail_length = 3;

// Horizontal space between bridge and ramp.
ramp_offset_from_bridge = 0;

ramp_offset = bridge_offset + bridge_width + ramp_offset_from_bridge;

// Thickness of the plate that connects feeders.
plate_thickness = bottom_thickness;


base_length = total_length;
base_height = bottom_thickness + part_slot_height + tape_slot_height;
base_width = tape_slot_width + 2*side_wall_width;

ramp_width = base_width;

module tape_slot_taper(x, y, a) {
  translate([x, y, 0])
  rotate([0, 0, a])
  translate([-3*side_wall_width/2, 0, 0])  cube([3*side_wall_width, eps1, tape_slot_height+eps2]);
}

module base_body() {
  cube([base_length, base_width, base_height]);
}

module parts_slot() {
 translate([-eps1, side_wall_width + tape_support_width_right, 0]) 
    cube([base_length+eps2, part_slot_width, part_slot_height]);  
}

module tape_slot() {
 a = tape_slot_taper_angle;

 translate([-eps1, (base_width-tape_slot_width)/2, 0]) 
     cube([base_length+eps2, tape_slot_width, tape_slot_height+eps2]);

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
  translate([0, (base_width-ramp_width)/2, 0]) 
  hull() {
    cube([eps1, ramp_width, eps1]);
    translate([ramp_length, 0, 0])  cube([eps1, ramp_width, ramp_height]);
 translate([ramp_length+1, 0, 0])  cube([eps1, ramp_width, ramp_height]);
    translate([2*ramp_length + 1, 0, 0])  cube([eps1, ramp_width, eps1]);
  }
}

//module top_hole(x, l, w) {
//  translate([x, (base_width-w)/2, -eps1]) cube([l, w, top_thickness + eps2]);
//}

module bridge_main() {
  bridge_height = bridge_gap + bridge_top_thickness;
  side_wall_length = bridge_width + ramp_offset_from_bridge + ramp_length;

  difference() {
    cube([bridge_width, base_width, bridge_height]);
    translate([-eps1, (base_width - tape_slot_width)/2, -eps1]) cube([bridge_width+eps2, tape_slot_width, bridge_gap+eps1]);
  }

  cube([side_wall_length, side_wall_width, bridge_height]); 

  translate([0, base_width - side_wall_width, 0]) cube([side_wall_length, side_wall_width, bridge_height]); 
}

module top_main() {
  difference() {
  cube([base_length, base_width, top_thickness]);
  //top_hole(top_hole_offset, top_hole_length, tape_slot_width);
}
  translate([ramp_offset, 0, top_thickness - eps1]) top_ramp();
}

module one_feeder() {
   base_main();
   translate([0, 0, base_height-eps1]) top_main();
   translate([bridge_offset, 0,  base_height + top_thickness - eps2]) bridge_main();
}

module main() {
  width = feeders_count*base_width + (feeders_count-1)*inter_feeder_space; 
  for ( i = [0 : feeders_count-1] ) {
    translate([0, i*(base_width + inter_feeder_space - eps1), 0]) one_feeder();
  }
  cube([base_length, width, plate_thickness]);
}

// NOTE: rotation around z for better view angle on thingieverse.

//translate([0, 0, base_length]) 
rotate([0, -90, 0]) 
main();








