$fn=200;

d1=19+0.25;
w = 1.6;
d2=d1+2*w;
h=68;

difference() {
  cylinder(d=d2, h=h);
  translate([0, 0, -1]) cylinder(d=d1, h=h+2);
}