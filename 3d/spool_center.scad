$fn=360;

d2=40;
w=1.6;

d1=d2-2*w;
h=75;



difference() {
  cylinder(d=d2, h=h);
  translate([0, 0, -1]) cylinder(d=d1, h=h+2);
}