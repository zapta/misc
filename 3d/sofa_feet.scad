// A wedge base for Ring.com Doorbell. Calibrated for the Pro version.

// Adding '0' to hide from Thingiverse customizer.
eps1 = 0.01 + 0;
eps2 = 2*eps1;

// Round faces smoothness.
$fn=64;

module inset_bottom(w=0.4, h=0.2, bounding_size = 200, eps=0.01) {
  if (w == 0 || h < 0) {
    children();
  } else {
    // The top part of the children without the inset layer.
    difference() {
      children();
      // TODO: use actual extended children projection instead
      // of a clube with arbitrary large x,y values.
      translate([0, 0, -9*h]) 
          cube([bounding_size, bounding_size, 20*h], center=true);
    }
    // The inset layer.
    linear_extrude(height=h+eps) offset(r = -w) projection(cut=true)
      children();
  }
}

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

module hole(d, h, x, y) {
  translate([x, y, -eps1]) cylinder(d=d, h=h+eps1);
}

module holes() {
  dx = 22;
  d1 = 6.6;
  d2 = 14.5;
  
  hole(d1, 30, dx, 0);
  hole(d2, 4.5, dx, 0);
  
  hole(d1, 30, -dx, 0);
  hole(d2, 4.5, -dx, 0);
  
  // For strength
  hole(5, 30, 40, 20);  
  hole(5, 30, 40, -20);  
  hole(5, 30, -40, 20);  
  hole(5, 30, -40, -20);  
  
  hole(5, 30, 0, 20);  
  hole(5, 30, 0, -20);
}

module main() {
  inset_bottom(w=0.4, h=0.4)
  difference() {
    union() {
      rounded_block(121, 71, 2, 3);
      rounded_block(102, 62, 5, 3);
      //rounded_block(85, 43, 12, 3);
      translate([22, 0, 0]) cylinder(d=25, h=6+2);
      translate([-22, 0, 0]) cylinder(d=25, h=6+2);
    }
    holes();
  }
}

main();

//difference() {
//  cylinder(d=40, h=1);
//  translate([0, 0, -1]) cylinder(d=6.5, h=10);
//}