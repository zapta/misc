$fn=32;

eps1 = 0.01;
eps2 = 0.02;

hole_d1 = 5+0.4;
hole_d2 = 8;
hole_d3 = 7;

hole_horiz_offset = 1;
hole_vert_offset = -5;

thickness = 5;
vert_angle = 25;
horiz_angle = 39;  // was 40

width = 15;
length = 22;  // was 22


// Operator to inset first layer to eliminate elephant foot.
// Children are assumed to be on the z=0 plane.
//module inset_first_layer(w=0.4, h=0.4, eps=0.01) {
//  if (w == 0 || h < 0) {
//    children();
//  } else {
//    difference() { 
//      children();  
//      // TODO: use actual extended children projection instead
//      // of a clube with arbitrary large x,y values.
//       cube([30, 30, 2*h], center=true);
//    }
//    linear_extrude(height=h+eps)
//      offset(r = -w) 
//        projection(cut=true)
//          translate([0, 0, -eps1]) children();
//  }
//}

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

module hole() {
  translate([0, 0, -15]) 
    cylinder(d1=2*10+hole_d2, d2=hole_d1, h=15+(hole_d2-hole_d1)/2);
  
  cylinder(d=hole_d1, h=15);
  
  translate([0, 0, 7]) cylinder(d=hole_d3, h=20);
}

module main() {
  difference() {
    rounded_block(length, width, thickness, 1);
    translate([hole_horiz_offset, hole_vert_offset, 0]) rotate([-vert_angle, horiz_angle, 0])  hole();
  }
}

//inset_first_layer() 
  translate([0, 0, thickness]) rotate([180, 0, 0]) main();

//hole();


