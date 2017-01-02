circlt_resolution = 360;
$fn = circlt_resolution;

// '+0' to hide in thingieverse's customizer.
eps1 = 0.01 + 0;
eps2 = eps1 * 2;

inner_diameter = 80;
bottom_thickness = 3;
wall_height = 3;
wall_thickness = 5;

text = "Xyz";
//texts = ["Teiko", "Rina", "Nir"];
text_size = 16
;
text_depth = 0.6;

text_vertical_offset =  0;
text_horizontal_offset = 0;

text_font = "Helvetica";

// Bottom chamfer.
chamfer1 = 1;

// Top outer chamfer.
chamfer2 = 0.5;

// Inner lower chamfer.
chamfer3 = 0.5;

// Inner upper chamfer.
chamfer4 = 0.5;

release_slots_r1 = 20;
release_slots_r2 = 39;

// c1, c2 are bottom and top chamfers, respectivly. Should be
// > 0 (eps is ok). Negative chamfer means expanstion.
module disc(d, h, c1, c2) {
  // Bottom
  cylinder(d1=d - 2*c1, d2 = d, h=abs(c1)+eps1);
  
  // Center
  translate([0, 0, abs(c1)]) cylinder(d=d, h = h - abs(c1) - abs(c2) + eps1);
  
  // Top
  translate([0, 0, h-abs(c2)]) cylinder(d1=d, d2 = d - 2*c2, h=abs(c2));
}

module coaster(text) {
  difference() {
    // Body
    disc(inner_diameter+2*wall_thickness, bottom_thickness + wall_height, chamfer1, chamfer2);
    
    // Main cavity
    translate([0, 0, bottom_thickness]) disc(inner_diameter, wall_height+eps1, chamfer3, -chamfer4);
   
    // Text
    translate([text_horizontal_offset, text_vertical_offset, bottom_thickness - text_depth])   linear_extrude(height = bottom_thickness) text(text, halign="center",valign="center", size=text_size, font=text_font);
    
    slots();
  }
}

module slots() {
  for (a = [0: 45: 359]) {
    slot(release_slots_r1, release_slots_r2, 2, a);
  }
}

module slot(r1, r2, w, a) {
  rotate([0, 0, a]) hull() {
    translate([r1-w/2, 0, bottom_thickness]) sphere(d=w, $fn=64);
    translate([r2-w/2, 0, bottom_thickness]) sphere(d=w, $fn=64);
  }   
}

rotate([0, 0, 45]) 
  coaster(text);

//slot(40, 10, 4);


