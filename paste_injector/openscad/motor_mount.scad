// This file generates two parts, the motor mount and a matching syringe holder plate.
// The motor mount has holes for 4 M4 threaded inserts, McMaster 94180A353. Push them
// in with a standard solder iron. Make sure to push 1-2 mm at a time, letting the 
// plastic part to cool down.

$fn=180;

shaft_hole_diameter = 8;

bottom_height = 2.5;
motor_mount_width = 45;

cavity_wall = 2;
cavity_height = 28;
cavity_diameter = 22;

motor_screws_space = 35;
motor_screws_holes_offset = 8;
motor_screws_holes_depth = 20;

syringe_screws_space = 31;
syringe_screws_holes_depth = 20;

total_height = bottom_height + cavity_height;

base_corner_radius1 = 5;  // convex side
base_corner_radius2 = 3;  // flat side
base_corner_offset  = 0;

syringe_holder_height1 = 3;
syringe_holder_height2 = 6;
syringe_hole_diameter = 16.5+1.0;
syringe_hole_wall = 3;

syringe_holder_screw_diameter = 4.0+0.5;
syringe_holder_screw_head_diameter = 9.0+0.5;

chamfer = 0.5;

eps1 = 0.001;
eps2 = 2*eps1;

// Hole for a M4 metal insert, mcmaster part number 94180A353.
// h is the total depth for the screw hole. Already includes an 
// extra eps1 at the opening side.
module m4_threaded_insert(h) {
  // Adding tweaks for compensate for my printer's tolerace.
  A = 5.3 + 0.3;
  B = 5.94 + 0.4;
  L = 7.9;
  D = 5.0;
  translate([0, 0, -eps1]) {
    // NOTE: diameter are compensated to actual print results.
    // May vary among printers.
    cylinder(d1=B, d2=A, h=eps1+L*2/3, $f2=32);
    cylinder(d=A, h=eps1+L, $f2=32);
    translate([0, 0, L-eps1]) cylinder(d=D, h=h+eps1-L, $f2=32);
  }
}

// c1, c2 are chamfers at bottom and top respectivly. s1, s2 are chamfers's slopes.
module chamfered_cylinder(d, h, c1, s1, c2, s2) {
    cylinder(d1=d-2*c1, d2=d, h=s1*c1);
    translate([0, 0, s1*c1-eps1]) cylinder(d=d, h=h-s1*c1-s2*c2+eps2);
    translate([0, 0, h-s2*c2]) cylinder(d1=d, d2=d-2*c2, h=s2*c2);
}

module motor_holes() {
  translate([motor_screws_space/2, -motor_screws_holes_offset, total_height]) 
      rotate([180, 0, 0]) 
      m4_threaded_insert(motor_screws_holes_depth);

 translate([-motor_screws_space/2, -motor_screws_holes_offset, total_height]) 
      rotate([180, 0, 0]) 
      m4_threaded_insert(motor_screws_holes_depth);
}

module syringe_screws() {
  translate([syringe_screws_space/2, 0, -eps1]) 
      m4_threaded_insert(syringe_screws_holes_depth);
  
  translate([-syringe_screws_space/2, 0, -eps1]) 
       m4_threaded_insert(syringe_screws_holes_depth);
}

// Hole at the bottom of the base for the shreded shaft.
module shaft_hole() {
 translate([0, 0, -eps1]) cylinder(d=shaft_hole_diameter, h=bottom_height+eps2, $f2=32);
}

// The motor mount before any substraction. It accepts a height parameter so 
// we can use this pattern also for the syringe holder.
module base_pattern(h) {
  hull() {
    cylinder(d=cavity_diameter+2*cavity_wall, h=h);
    
    // Flat side
    translate([motor_mount_width/2-base_corner_radius2, -(cavity_diameter+2*cavity_wall)/2+base_corner_radius2, 0]) cylinder(r=base_corner_radius2, h=h);
    
    translate([-(motor_mount_width/2-base_corner_radius2), -(cavity_diameter+2*cavity_wall)/2+base_corner_radius2, 0]) cylinder(r=base_corner_radius2, h=h);
    
    // Concave side
    translate([motor_mount_width/2-base_corner_radius1, base_corner_offset, 0]) 
        cylinder(r=base_corner_radius1, h=h);
    
    translate([-(motor_mount_width/2-base_corner_radius1), base_corner_offset, 0]) 
        cylinder(r=base_corner_radius1, h=h);
  }
}

// The coupler cavity cut.
module cavity() {
  translate([0, 0, bottom_height]) cylinder(d=cavity_diameter, h=total_height, $fn=64);  
}

module motor_mount() {
  difference() {
    base_pattern(total_height);
    cavity();
    shaft_hole();
    motor_holes();
    syringe_screws();
  }
}

module syringe_holder_blank() {
  hull() {
    translate([0, 0, syringe_holder_height1]) rotate([0, 180, 0]) 
        base_pattern(syringe_holder_height1);
  
    chamfered_cylinder(syringe_hole_diameter+2*syringe_hole_wall, syringe_holder_height1+syringe_holder_height2, eps1, 1.0, 2.0, 1.0);
  } 
}

module syringe_holder() {
  total_h=syringe_holder_height1+syringe_holder_height2+eps2;
  difference() {
    syringe_holder_blank();
    
    // Syringe hole + chamfer;
    translate([0, 0, -eps1]) {
      cylinder(d=syringe_hole_diameter, h=total_h+eps2);
      cylinder(d1=syringe_hole_diameter + 2*chamfer, d2=eps1, 
          h=(syringe_hole_diameter + 2*chamfer)/2);
    }
    
    
    
    // Screw holes + chamfers.
    translate([-syringe_screws_space/2, 0, -eps1]) {
      cylinder(d=syringe_holder_screw_diameter, h=total_h+eps2);
      cylinder(d1=syringe_holder_screw_diameter + 2*chamfer, d2=eps1, 
          h=(syringe_holder_screw_diameter + 2*chamfer)/2);
    }
    
    translate([syringe_screws_space/2, 0, -eps1]) {
      cylinder(d=syringe_holder_screw_diameter, h=total_h+eps2);
      cylinder(d1=syringe_holder_screw_diameter + 2*chamfer, d2=eps1, 
          h=(syringe_holder_screw_diameter + 2*chamfer)/2);
    }
    
    // Screw heads insets.
    translate([-syringe_screws_space/2, 0, syringe_holder_height1]) 
        cylinder(d=syringe_holder_screw_head_diameter, h=syringe_holder_height2+eps2);
    
    translate([syringe_screws_space/2, 0, syringe_holder_height1]) 
        cylinder(d=syringe_holder_screw_head_diameter, h=syringe_holder_height2+eps2);
  }  
}

module main() {
  motor_mount();
  translate([0, -40, 0]) syringe_holder();
}

main();

 
