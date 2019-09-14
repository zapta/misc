$fn=16;

difference() {
cube([16, 13, 1]);

translate([3.5, 3.2, -1]) cylinder(d=3, h=3);

translate([12.5, 3.2, -1]) cylinder(d=3, h=3);
}