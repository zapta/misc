
// Number of faces per 360 degrees. 
$fn=180;

// Inner diameter of hole for shaft 1.
id1 = 5.5; 

// Inner diameter of hole for shaft 2.
id2 = 4.5;  

// Outer diameter.
od = 15;

body_offset_from_center = 2;

// Length of hole for shaft 1.
h1 = 10;

// Length of hole for shaft 2.
h2 = 12;


// Width of the slot along the coupler.
slot_width = 2.0;

// Total coupler length;
total_height = h1 + h2;

// Diameter of the screw holes.
screw_hole_diameter = 3.3;

// Diamter of the inset for the screws head.
screw_head_diamter = 5.7;

// Diamter of the inset for the screws nuts.
screw_nut_diameter = 6.5;

// Distance between screw head and nut.
screw_head_to_nut = 7;

// Offset of the screws' centers from the coupler's center.
hole_offset_from_center = 5;

// Offset of the screws' centers from the coupler ends.
hole_offset_from_end = 6;

// Direction of screw 1.
direction1 = 1;
// Direction of screw 2;
direction2 = -1;

phase = 1;

//----------

clearance_diamter = 2*(od/2 + body_offset_from_center);

echo("*** total_height: ", total_height);
echo("*** clearance_diamater: ", clearance_diamter);

// Small measures, use to menatain manifold.
eps1 = 0.001;
eps2 = 2*eps1;

module shafts_phases() {
  translate([0, 0, -eps1]) 
      cylinder(d1=id1+2*phase, d2=eps1, h=(id1+phase)/2); 
  translate([0, 0, total_height-(id2+phase)/2+eps1]) 
      cylinder(d1=eps1, d2=id2+2*phase, h=(id2+phase)/2);
}

module main_cylinder() {
  hull() {
    cylinder(d1=od-2*phase, d2=od, h=phase);
    translate([0, 0, total_height-phase]) cylinder(d1=od, d2=od-2*phase, h=phase);
  }
}

// direction should be 1 or -1. 
module screw(h, direction) {
  translate([0, hole_offset_from_center, h])
  rotate([0, direction*90, 0])
  union() {
    translate([0, 0, -od/2]) cylinder(d=screw_hole_diameter, h=od); 
    translate([0, 0, screw_head_to_nut/2]) cylinder(d=screw_head_diamter, h=od/2);
    translate([0, 0, -(od + screw_head_to_nut)/2]) cylinder($fn=6, d=screw_nut_diameter, h=od/2);
  }
}

module body() {
  difference() {
    translate([0, body_offset_from_center, 0]) main_cylinder();
    
    translate([0, 0, -eps1]) cylinder(d=id1, h=h1+eps2); 
    translate([0, 0, h1]) cylinder(d=id2, h=h2+eps1); 
    translate([-slot_width/2, 0, -eps1]) cube([slot_width, od+eps1, total_height+eps2]);
  }
}

module main() {
  difference() {
    body();
    screw(hole_offset_from_end, direction1);
    screw(total_height - hole_offset_from_end, direction2);
    shafts_phases();
  }
}

main();