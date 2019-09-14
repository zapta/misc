$fn=64;

d1=19;
d2=3;
h=3;

difference() {
  cylinder(d=d1, h=h);
  translate([0, 0, -0.1]) cylinder(d=d2, h=h+0.2);
}