
$fn=256;
h=10;
id=15;
eps = 0.01;

module ring(w) {
difference() {
  od=id+2*w;
  cylinder(h=h, d=od);
  translate([0, 0, -eps]) cylinder(h=h+2*eps, d=id);
}
}

ring(1.45);

