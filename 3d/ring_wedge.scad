// A wedge base for Ring.com Doorbell. Calibrated for the Pro version.

// Adding '0' to hide from Thingiverse customizer.
eps1 = 0.01 + 0;
eps2 = 2*eps1;

// Base width. Should match the doorbell with cover.
width = 47.16;  // along y

// Base length. Should match the doorbell with cover.
length = 115.25;  // along x

// Min thicknes among the 4 corners
min_thickness = 2;  

// Camera pan angle (0 = none, positive = right, negative = left)
pan_angle = 5;

// Camera pitch angle (0 = none, positive = up, negative = down)
pitch_angle = 2;

// Radius of base corner.
corner_radius = 2;

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

// Text vertical offset from the center.
text_offset = 25;

// Text font size.
text_size = 7;

// Text font.
text_font = "Helvetica:black";

// Text depth;
text_depth = 1;

// The text itself.
text_msg = "FRONT";

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
  dh1 = (length/2) *tan(abs(pitch_angle));
  dh2 = (width/2) *tan(abs(pan_angle));
  center_thickness = dh1 + dh2 + min_thickness;
  translate([0, 0, center_thickness]) 
    rotate([-pan_angle, -pitch_angle, 0]) 
      rounded_block(length*4, width*4, 2*width, 1);
}

module screw_hole() {
  translate([screw_hole_spacing/2, 0, -eps1]) 
      cylinder(d=screw_hole_diameter, h=length);
}

module wires_hole() {
  translate([wire_hole_offset, 0, -eps1]) rounded_block(wire_hole_size, wire_hole_size, length, wire_hole_corner_radius);
}

module label() {
  translate([-text_offset, 0, -eps1]) linear_extrude(height = text_depth+eps1) 
rotate([0, 0, 90]) mirror([1, 0, 0]) text(text_msg, halign="center",valign="center", size=text_size, font=text_font);
}

module body() {
  difference() {
    rounded_block(length, width, 2*width, corner_radius);
    slope();
    wires_hole();
    screw_hole();
    mirror([1, 0, 0]) screw_hole();
    label();
  }
}

body();
