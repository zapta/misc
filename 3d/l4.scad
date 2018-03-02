
difference() {
import("./climbing.stl", convexity=3);

translate([15, -1, 0]) rotate([0, 0, -8]) mirror([0, 1, 0]) linear_extrude(height = 5)
 text("L4", halign="center",valign="center", font="Ariel Sans:style=Bold", size=5);
}
