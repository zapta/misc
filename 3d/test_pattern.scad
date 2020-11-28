w=60;
h = 8;
difference() {
  translate([-w/2, 0, 0]) cube([w, 150, h]);
  translate([-w/8, 5, -1]) cube([w/4, 5, h+2]);
}
  