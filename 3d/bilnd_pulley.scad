$fn=60;

difference() {
cylinder(d=40, h=10);

translate([0, 0, 7])
rotate_extrude(convexity = 10)
translate([20, 0, 0])
circle(d = 3);
  
  translate([0, -25, -0.1])
  cube(50);
}