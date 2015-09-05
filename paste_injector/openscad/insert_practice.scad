// Test part for practicing threaded inserts insertion using a 
// solder iron..

$fn=32;

h1=8;
h2=10;

eps1 = 0.001;
eps2 = 2*eps1;

module hole(x, y, d1, d2, ratio, d3) {
  translate([x, y, -eps1]) cylinder(d1=d1, d2=d2, h=ratio*h1+eps2);
  translate([x, y, ratio*h1]) cylinder(d=d2, h=(1-ratio)*h1+eps1);
  translate([x, y, 8]) cylinder(d=d3, h=h1);
}

module holes() {
   hole(0,  0,  6.0, 5.3, 0.5, 7);
//   hole(0, 10,  5.0, 5.0, 0.5, 6);
//   hole(0, 20,  6.0, 5.0, 0.5, 6);
//   hole(0, 30,  6.0, 5.5, 0.5, 6);
}

module main() {
  difference() {
    translate([-5, -5, 0]) cube([10, 10, 10]);
    holes();
    translate([-5, -10, -2]) rotate([0, 0, 45]) cube([5, 5, h2+eps2]);
  }
}

rotate([180, 0, 0]) main();