// A wedge base for Ring.com Doorbell. Calibrated for the Pro version.

// Adding '0' to hide from Thingiverse customizer.
eps1 = 0.01 + 0;
eps2 = 2*eps1;

// Base width. Should match the doorbell with cover.
width = 47.16;  // along y

// Base length. Should match the doorbell with cover.
length = 115.25;  // along x

// Base width  at the bottom of the doorbell.
bottom_thickness = 3;  // along z

// Base width at the  top of the doorbell.
top_thickness = 14.2;  // along z

max_thickness = max(bottom_thickness, top_thickness);

// Camera pan angle (0 = none, positive = right, negative = left)
pan_angle = 0;

// Radius of base corner.
corner_radius = 1;

// Spacing between screw hole centers.
screw_hole_spacing = 105.7;

// Diameter of screw holes.
screw_hole_diameter = 5;

// Size of the wires hole.
wire_hole_size = 26;

// Offset between centers of wire hole and base.
wire_hole_offset = 10;

// Radius of the wire hole corners
wire_hole_corner_radius = 4;

// Round faces smoothness.
$fn=64;


module corner_post(l, w, h, r) {
     translate([l/2-r, w/2-r, 0]) 
      cylinder(r=r, h=h);  
}

module rounded_block(l, w, h, r) {
  hull() {
    corner_post(l, w, h, r);
    mirror([1, 0, 0]) corner_post(l, w, h, r);
    mirror([0, 1, 0]) corner_post(l, w, h, r);
    mirror([1, 0, 0]) mirror([0, 1, 0]) corner_post(l, w, h, r);
  } 
}

module slope() {
  offset = sin(abs(pan_angle)) * width/2;
  hull() {
    translate([-length/2-eps1, 0, top_thickness+offset]) 
      rotate([-pan_angle, 0, 0]) translate([0, -width-eps1, 0]) 
        cube([eps1, 2*width+eps2, 2*max_thickness]);
    translate([length/2, 0, bottom_thickness+offset]) 
      rotate([-pan_angle, 0, 0]) translate([0, -width-eps1, 0]) 
        cube([eps1, 2*width+eps2, 2*max_thickness]);
  }
}

module screw_hole() {
  translate([screw_hole_spacing/2, 0, -eps1]) 
      cylinder(d=screw_hole_diameter, h=max_thickness*2);
}

module wires_hole() {
  translate([wire_hole_offset, 0, -eps1]) rounded_block(wire_hole_size, wire_hole_size, max_thickness*2, wire_hole_corner_radius);
}


module body() {
  difference() {
    rounded_block(length, width, 2*max_thickness, corner_radius);
    slope();
    wires_hole();
    screw_hole();
    mirror([1, 0, 0]) screw_hole();
  }
}

body();




  
 