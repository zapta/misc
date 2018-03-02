// A sacrificial post to slow allow small layers to coll off.
// Scale verticaly ONLY in the slicing program to the height of the 
// printed part and place it at a far corner of the building plate.

$fn=64;

eps1 = 0.01;
eps2 = 2 * eps1;

// Height
h = 20;
// Diameter
d = 10;
// Adjust wall thickness to be sliced to one vertical layer.
wall = 0.5;
// Base height. Used to improve first layer adhesion.
base = 0.6;

difference() {
  cylinder(d=d, h=h);
  translate([0, 0, base]) cylinder(d=d-2*wall, h=h);
}