$fn=180;

eps1 = 0.01;
eps2 = 2*eps1;

d1=5;
d2=55;  // 70

module v1() {
difference() {
  sphere(d=d2);
    
  translate([-(d2+eps2)/2, -(d2+eps2)/2, -d2/2-eps1]) cube([d2+eps2, d2+eps2, d2/2+eps1]);
    
  translate([d1, 0, -eps1]) cylinder(d=d1, h=eps2+d2/2, $fn=16);
  translate([-d1, 0, -eps1]) cylinder(d=d1, h=eps2+d2/2, $fn=16);
    
  translate([0, 0, d2/2]) hull() {
    translate([d1, 0, 0]) sphere(d=d1, $fn=16); 
    translate([-d1, 0, 0]) sphere(d=d1, $fn=16); 
  }
}
}

k1 = 1.1;
k = 0.92;
k2 = (k1 * k)/2;
s = d1*1.5;

//'v1();

difference() {
 scale([1, 1, k1]) sphere(d=d2);
    
    // cut top
 translate([0, 0, d2*k2]) cylinder(d=d2+eps1, h=d2);
    
    // Cut bottom
 translate([0, 0, -d2*k2]) mirror([0, 0, 1]) cylinder(d=d2+eps1, h=d2);
    
      // hole 1
      translate([s/2, 0, -(k1*d2/2+eps1)]) cylinder(d=d1, h=1.3*d2+eps2, $fn=16);
    // hole 2
     translate([-s/2, 0, -(k1*d2/2+eps1)]) cylinder(d=d1, h=1.3*d2+eps2, $fn=16);

// string cavity
  translate([0, 0, k2*d2]) hull() {
    translate([s/2, 0, 0]) sphere(d=d1, $fn=16); 
    translate([-s/2, 0, 0]) sphere(d=d1, $fn=16); 
  }

}

