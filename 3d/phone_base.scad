$fn=64;


// top surface
l1=55;
w1=50;
r1=15;

side_offset=0;
forward_offset=-5;

// Bootom surface
l2=56;
w2=50;
r2=5;

yaw=65;
pitch=-30;
roll=-18;

height=26;

hole_spacing = 38;
hole_diameter = 2;
hole_depth = 23;

eps=0.01;

module plate(l, w, r) {
  hull() {
    for(i =[-1, 1]) {
      for(j =[-1, 1]) {
        translate([i*(l/2-r), j*(w/2-r), 0]) cylinder(r=r, h=eps);
      }
    }
  }
}

module top_transform() {
  translate([side_offset, forward_offset, height-eps]) 
    rotate([0, 0, yaw]) 
    //translate([-offset, 0, 0]) 
    rotate([roll, 0, 0])
    rotate([0, pitch, 0]) 
    children();
}

module holes() {
  for(i=[0, 1]) {
    mirror([i, 0, 0]) 
      translate([-hole_spacing/2, 0, -hole_depth+2*eps]) 
      cylinder(d=hole_diameter, h=hole_depth+2*eps) ;
   
      // TODO: add chamfer at top of the hole 
  }
}

module main() {
  difference() {
    hull() {
      top_transform() plate(l1, w1, r1);
      plate(l2, w2, r2);
    }
    top_transform() holes();
  }
}

main();

//plate(l1, w1, r1);
//holes();
