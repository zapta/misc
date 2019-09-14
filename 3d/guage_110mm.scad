
$fn=32;


w=10;
h=10;
d = 3;
l1=120-w;
l2=25;

difference() {
  translate([-w, -w, 0]) {
    #cube([l1+w, w, h]);
    cube([w, l2+w, h]);
  }
  translate([0, 0, -0.1]) cylinder(d=d, h=h+0.2);
}

