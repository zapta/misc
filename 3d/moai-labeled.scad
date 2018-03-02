
eps=0.01;

difference() {
  union() {
   translate([0, 55, 0]) rotate([90, 0, 0]) import("moai-new.stl", convexity=3);
   // translate([-15, -5, 0]) cube([30, 10, 2]);
  }

 translate([0, 0, -eps]) mirror([1, 0, 0]) linear_extrude(height = 0.6) text("RINA  2017", halign="center",valign="center", size=3, font="Helvetica:black");
  
}

