

$fn=32;

eps1=0.001;
eps2 = 2*eps1;


thickness = 3;
//side_width = 12;
hole_height = 15;  // from bottom of opening.
hole_center_offset = 5;  // from top edge
opening = 29 - thickness;
hole1_diameter = 3.7;
hole2_diameter = 3;



total_length = opening + 2*thickness;
total_height = thickness + hole_height + hole_center_offset;
total_width = 12;

module u_shape() {
difference() {
  cube([total_length, total_width, total_height]);

  translate([thickness, -eps1, thickness]) cube ([opening, total_width + eps2, total_height - thickness + eps1]);
  }
}

module hole1() {
translate([-eps1, total_width/2, thickness + hole_height]) rotate([0, 90, 0]) cylinder(d=hole1_diameter, h=thickness+eps2);
}

module hole2() {
translate([total_length - thickness - eps1, total_width/2, thickness + hole_height]) 
  rotate([0, 90, 0]) 
  cylinder(d=hole2_diameter, h=thickness+eps2);
}

module rib() {
  cube([total_length, thickness, thickness + hole_height - hole_center_offset]);
}

module main() {
difference() {
  u_shape();
  hole1();
  hole2();
}
}


main();

translate([0, -20, 0]) difference() {
union() {
cylinder(d=12, h=2);
translate([0, 0, 2-eps1]) cylinder(d=6, h=1.5);
}
translate([0, 0, -eps1]) cylinder(d=3.2, h=4);
}

//translate([0, (total_width-thickness)/2, 0]) rib();
//, total_width