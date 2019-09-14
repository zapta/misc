
l1=10;
l2=20;
w=3;
h=5;

difference() {
  cube([2*w+l1, 2*w+l2, h]);
  translate([w, w, -0.01]) cube([l1, l2, h+0.02]);
}