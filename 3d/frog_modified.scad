
// Printing: PLA, 200c, Prusa Slicer, 0.2mm, 2 perimeters, 3 layers top/bottom, 
// honeycomb infill 15%.

module frog() {
  rotate([0, 0, 90]) translate([-150.1, -153, 0]) {
    import("money_frog_hollow_body_modified.stl", convexity=10);
  }
}

module bar() {
  translate([-1, -0.9, 0]) cube([25, 1.8, 3]);
}

module base() {
  translate([0, -18, 0]) bar();
  translate([0, -12, 0]) bar();

  translate([0, 18, 0]) bar();
  translate([0, 12, 0]) bar();

  translate([-2, 0, 0]) bar();

  translate([5, -25, 0]) cube([20, 50, 2]);
}

//rotate([0, 0, 90])
difference() {
  union() {
    frog();
    base();
  }
  translate([-50, -50, -1]) cube([100, 100, 1.25]);
}


