



// Tray external width.
width = 60;

// Tray external length.
length = 100;

// Tray external height.
height = 13;

// Tray corner radius
corner_radius = 5;

// Thickness of wall around the tray
wall_thickness = 2;

// Thickness of the base
base_thickness = 2;

// Spout width at the tray end.
spout_base_width = 35;

// Spout width at the outer end.
spout_tip_width = 25;

// Spout end height as a fraction of the tray wall height.
spout_tip_height_fraction = 0.7;

// Base thickness at the outer end of the spout.
spout_tip_base_thickness = 0.8;

// Controls spout length. Tweak to get desired spout length. 
spout_length_control = 20;

// 0 for right handed, 1 for left handed.
left_hand = 0;  

// Circle smoothness (number of faces).
$fn = 90;

spout_vertical_angle = max(0, atan((height - height * spout_tip_height_fraction)/ spout_length_control));

// Adding '0' to hide in thingiverse customizer.
eps1 = 0.01 + 0;
eps2 = 2 * eps1;


module rounder_cube(w, l, h, r) {
    dx = l/2-r;
    dy = w/2-r;
  hull() {
      translate([dx, dy, 0]) cylinder(r=r, h=h);
      translate([dx, -dy, 0]) cylinder(r=r, h=h);
      translate([-dx, dy, 0]) cylinder(r=r, h=h);
      translate([-dx, -dy, 0]) cylinder(r=r, h=h);
  }
}

module spout() {
  hull() {
    translate([0, -spout_base_width/2, 0]) cube([eps1, spout_base_width, height]);
    translate([spout_length_control-eps1, -spout_tip_width/2, 0]) cube([eps1, spout_tip_width, height]);
  }
}

module spout_slot() {
  hull() {
    translate([-eps1, -(spout_base_width-sqrt(2)*2*wall_thickness)/2, base_thickness]) 
      cube([eps1, spout_base_width-sqrt(2)*2*wall_thickness, height]);
      
    translate([spout_length_control, -(spout_tip_width-2*wall_thickness)/2, spout_tip_base_thickness]) cube([eps1, spout_tip_width-2*wall_thickness, height]);
  }
  
  // Extra cut in case the spout end include the tray's missing 
  // corner so we don't have a leftover from that corner.
  translate([spout_length_control - eps1, -width, -height]) cube([width, 2*width, 3*height]);
}


module main() {
  mirror([left_hand, 0, 0])
  difference() {
     union() {
          //bowel();
               rounder_cube(width, length, height, corner_radius);

          translate([
            length/2-(spout_base_width/2)/sqrt(2), 
            width/2-(spout_base_width/2)/sqrt(2), 
            0]) 
                rotate([0, 0, 45]) spout();
     }
     
     translate([0, 0, base_thickness]) 
     rounder_cube(width-2*wall_thickness, length-2*wall_thickness, height-base_thickness+eps1, max(0.1, corner_radius-wall_thickness));
     
     translate([
            length/2-(spout_base_width/2)/sqrt(2), 
            width/2-(spout_base_width/2)/sqrt(2), 
            0]) 
                rotate([0, 0, 45]) spout_slot();
     
     translate([
         length/2-(spout_base_width/2)/sqrt(2), 
         width/2-(spout_base_width/2)/sqrt(2), 
         height])  
       rotate([0, 0, 45]) 
       rotate([0, spout_vertical_angle, 0]) 
       cylinder(d=2*length, h=height);
 }
     
}

//spout_slot();



main();
