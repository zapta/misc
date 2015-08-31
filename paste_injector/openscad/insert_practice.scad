// Test part for practicing threaded inserts insertion using a 
// solder iron..

$fn=32;

h=8;

eps1 = 0.001;
eps2 = 2*eps1;

module hole(x, y, d1, d2, ratio, d3) {
  translate([x, y, -eps1]) cylinder(d1=d1, d2=d2, h=ratio*h+eps2);
  translate([x, y, ratio*h]) cylinder(d=d2, h=(1-ratio)*h+eps1);
  translate([x, y, h]) cylinder(d=d3, h=10);
}

module holes() {
   hole(0,  0,  5.0, 4.0, 0.3, 4.5);
   hole(0, 10,  5.0, 4.0, 0.3, 4.5);
   hole(0, 20,  5.0, 4.0, 0.3, 4.5);
   hole(0, 30,  5.0, 4.0, 0.3, 4.5);
}

difference() {
  translate([-5, -5, 0]) cube([10, 40, 10]);
  holes();
  translate([-5, -10, 2]) rotate([0, 0, 45]) cube([5, 5, h+eps2]);
}