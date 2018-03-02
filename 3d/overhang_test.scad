eps = 0.01;

w = 4;
s = 2;
h = 8;
n = 6;
a0 = 40;

pitch = w+s;

module finger(a) {
  l = 10;
  hull() {
    cube([l, w, eps]);
    translate([0, 0, h-eps]) cube([l+tan(a)*h, w, eps]);
  }
}

module main() {
  for (i = [0:n-1]) {
    a = a0 + (n-1-i)*5;
    echo("Angle: ", a);
    translate([0, pitch*i]) finger(a);
    //finger(45);
  }

  cube([6, n*pitch-s, h/2]);
}

rotate([0, 0, -90]) main();