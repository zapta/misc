// 28BYJ-48 stepper motor to M4 threaded shaft coupler. 

// Number of faces per 360 degrees. 
$fn=180;

// --- Motor end
// Inner diameter.
id1 = 5.0 + 0.7; 
// Length of hole for shaft 1.
h1 = 10;
// Width between the flatten sides of the motor shaft hole.
w1 = 3.0 + 0.5;
// Height of full round hole at the motor end.
motoer_base_height = 3.5;

// --- M4 threaded shart end
// Inner diameter of hole for shaft 2. This one fits the 
// M4 threded shaft.
id2 = 4.0 + 0.5;  
// Length of hole for shaft 2.
h2 = 12;

// --- Body Cylinder
od = 15;
body_offset_from_center = 2;
// Width of the slot along the coupler.
slot_angle = 12;
// Total coupler length;
total_height = h1 + h2;

// --- Clamping screws
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
hole_offset_from_end = 5;

// Other
shaft_chamfer = 0.5;
body_chamfer = 1;

// Coupler's body is excentric. This is the diameter, center at the shafts' center, 
// of the required clearance for the coupler.
bounding_diamter = 2*(od/2 + body_offset_from_center);

// Print some info
echo("*** total_height: ", total_height);
echo("*** bounding_diamater: ", bounding_diamter);

// Small measures, use to menatain manifold.
eps1 = 0.001;
eps2 = 2*eps1;

// Generate a cylinder which is cut on both sides. Used to match the 
// motor shaft end.
module flatten_cylinder(d, w, h) {
  intersection() {
    cylinder(d=d, h=h);
    translate([-d, -w/2, -eps1])  cube([2*d, w, h+eps2]);
  }
}

// Chamfers for the top and bottom shaft holes.
module shafts_chamfers() {
  translate([0, 0, -eps1]) 
      cylinder(d1=id1+2*shaft_chamfer, d2=eps1, h=(id1+shaft_chamfer)/2); 
 
  translate([0, 0, total_height-(id2+shaft_chamfer)/2+eps1]) 
      cylinder(d1=eps1, d2=id2+2*shaft_chamfer, h=(id2+shaft_chamfer)/2);
}

// The blank cylinder of the boddy. Includes top and bottom chamfers.
module body() {
  hull() {
    cylinder(d1=od-2*body_chamfer, d2=od, h=body_chamfer);
    translate([0, 0, total_height-body_chamfer]) cylinder(d1=od, d2=od-2*body_chamfer, h=body_chamfer);
  }
}

// Cut for one screw, with its nut.
module screw(h) {
  translate([0, hole_offset_from_center, h])
  rotate([0, -90, 0])
  union() {
    translate([0, 0, -od/2]) cylinder(d=screw_hole_diameter, h=od); 
    translate([0, 0, screw_head_to_nut/2]) cylinder(d=screw_head_diamter, h=od/2);
    translate([0, 0, -(od + screw_head_to_nut)/2]) cylinder($fn=6, d=screw_nut_diameter, h=od/2);
  }
}

// The clamping wedge slot.
module slot() {
  intersection() {
    translate([0, -((od/2)-body_offset_from_center), -1]) 
    hull() {
      rotate([0, 0, slot_angle/2]) cube([eps1, 2*od, total_height+2]);
      rotate([0, 0, -slot_angle/2]) cube([eps1, 2*od, total_height+2]);
    }
    translate([-od/2, 0, -1]) cube([od, od, total_height+2]);
  }
}

// The entire coupler.
module main() {
  difference() {
    translate([0, body_offset_from_center, 0]) body();
    translate([0, 0, -eps1]) flatten_cylinder(id1, w1, h1+eps2);
    translate([0, 0, -eps1]) cylinder(d=id1, h=motoer_base_height);
    translate([0, 0, h1]) cylinder(d=id2, h=h2+eps1); 
    screw(hole_offset_from_end);
    screw(total_height - hole_offset_from_end);
    slot();
    shafts_chamfers();
  }
}

main();

