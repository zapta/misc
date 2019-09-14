// Flashforge tube guide.

// Holder tilt angle in degrees.
angle = 15;
// Distance of the tube holders from the printer case.
distance_from_case = 20;

// Controls the distance between the centerlines of the bases.
base_width = 51;

half_base_width = base_width / 2;

// Width of the fillament slots.
filament_slot_width = 2.5;
// Inner diameter of the tube holders.
hole_diameter = 6.2;
// Length of the tube holder holes.
holder_length = 20;
// Thickness of the tube holder wall. Affects flexibility.
hole_wall = 2.5;
// Chamfer at the tube holder holes ends.
hole_chamfer = 1;

/* [Hidden] */

$fn=90;
eps1 = 0.001;
eps2 = eps1 * 2;

// Side is 1 or -1.
module base_bar(side) {
  translate([-32.5, side*half_base_width, 3]) rotate([0, 90, 0]) cylinder(d=6, h=65);
}

module base_bars() {
  base_bar(1);
  base_bar(-1);
}

// Side is 1 or -1.
module tube_holder(side) {
  translate([-17, side*half_base_width, distance_from_case+3]) rotate([0, 90-angle, 0]) 
  difference() {
    cylinder(d=hole_diameter+2*hole_wall, h=holder_length);
    // Tube hole
    translate([0, 0, -eps1]) 
      cylinder(d=hole_diameter, h=holder_length+eps2); 
    // Filament slots
    translate([-20, -filament_slot_width/2, -eps1]) 
      cube([20, filament_slot_width, holder_length+eps2]);
    // Bottom chamfer
    translate([0, 0, -eps1]) 
      cylinder(d1=hole_diameter+2*hole_chamfer, d2 = hole_diameter - eps2, h=hole_chamfer);
    // Top chamfer
    translate([0, 0, holder_length-hole_chamfer+eps1]) 
      cylinder(d1=hole_diameter, d2= hole_diameter+2*hole_chamfer,  h=hole_chamfer);
  }
}

module tube_holders() {
  tube_holder(1);
  tube_holder(-1);
}

module cross_bar() {
  translate([-16, -(half_base_width-4.5), distance_from_case]) rotate([0, -angle, 0]) cube([holder_length, base_width-9, 4]);
}

// Side is 1 or -1.
module pillar(side) {
  hull() {
    // Top strip.
    translate([-15.9, side*half_base_width-2, distance_from_case-1]) rotate([0, -angle, 0]) 
      cube([holder_length-0.2, 4, eps1]);

    // Bottom strip.
    translate([-16, side*half_base_width-2, 3]) cube([32, 4, eps1]);
  }
}

module pillars() {
  pillar(1);
  pillar(-1);
}

module main() {
  base_bars();
  cross_bar();
  tube_holders();
  pillars();
}

// For design
//main();

// For printing (with support at the bottom, less visible)
rotate([0, 0, 0]) main();

//base_bar(1);
