


l1=100;
l2=20;
w=8;
h=12;

cube([l2, 8, h]);
cube([w, l1, h]);
translate([0, l1-w, 0]) cube([l2, w, h]);