$fn=40;

k = 0.5;

difference() {
  union() {
    intersection() {
      translate([0, 0, -1]) scale([k, k, k])  import("my_fat_cat.stl", convexity=3);

      cylinder(d=100, h=50);
    }
  }

  // Magnet cavity
  translate([6, 0, 0.6]) #cylinder(d=9.5, h=15);


  // Release hole
  //translate([3.9, 0, -0.1]) #cylinder(d=1, h=5);
}
