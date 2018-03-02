

$fn=128;  // 128

eps=0.01;

height = 22;
r1=2;
r2=2;
d1=15;
d2=10;

hole_d = 3;

cavity_d = 8;
cavity_h = 17;
chamfer = 0.5;

module donut(r1, r2) {
  translate([0, 0, 0]) 
    rotate_extrude()
      translate([r2-r1, 0, 0])
        intersection() {
          circle(r = r1);
          square(r1);
        }
}


module rounded_cone(r1, r2, d2, d2, h) {
  hull() {
    translate([0, 0, r1]) mirror([0, 0, 1]) donut(r1, d1/2);
    translate([0, 0, h-r2]) donut(r2, d2/2);
  }
}

module main() {
  difference() {
    rounded_cone(r1, r2, d1, d2, height);
    
    translate([0, 0, -eps]) cylinder(d=hole_d, h=height+2*eps);
    translate([0, 0, height-chamfer]) cylinder(d1=hole_d, d2=hole_d+2*chamfer, h=chamfer+eps);

    translate([0, 0, -eps]) cylinder(d=cavity_d, h=cavity_h+eps);
  }
}

main();


//donut(3, 10);
//#cylinder(d=d1, h=height);

//rotate_extrude()
//      translate([4, 0, 0])
//intersection() {
//circle(d=10);
//square(10);
//}

//#cylinder(d=15, h=5);