$fn=64;

eps=0.01;

module chamfer(l, r) {
  difference() {
    translate([0, -r, 0]) cube([l, r, r]);
    translate([-eps, -r, r]) rotate([0, 90, 0]) cylinder(r=r, h=l+2*eps);
  }
}

module slot() {
  translate([25, 23, 5])  mirror([0, 1, 0]) mirror([1, 0, 0])  {
      cube([60, 5, 5]); 

translate([0, 0, 5/2]) rotate([-90, 0, 0]) cylinder(d=5, h=5);
}
}



module main() {
  
difference() {
minkowski() {
  union() {
difference() {
  translate([-60/2, -50/2, 0]) cube([60, 50, 12]);
  translate([-60/2-eps, -50/2+5, 3]) cube([60+2*eps, 50-2*5, 12]);
  
 

}
for (i = [0, 1]) {
  mirror([0, i, 0]) translate([-60/2, 50/2-5, 3-eps]) #chamfer(60, 1);
}

}

sphere(d=2);
}
 slot();
  mirror([0, 1, 0]) slot();
}
}

main();





