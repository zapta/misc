$fn=128;

h=10;
chamfer=1;
d1=10;
wall=3;
space=0.35;

eps=0.01;

// Inner
cylinder(d1=d1-2*chamfer, d2=d1, h=chamfer+eps);
translate([0, 0, chamfer]) 
    cylinder(d=d1, h=h-2*chamfer);
translate([0, 0, h-chamfer-eps]) 
    cylinder(d1=d1, d2=d1-2*chamfer, h=chamfer+eps);

// Outer
difference() {
  cylinder(d=d1+2*wall+2*space, h=h);
  translate([0, 0, -eps]) 
      cylinder(d=d1+2*space, h=h+2*eps); 
  translate([0, 0, -eps]) 
      cylinder(d1=d1+2*space+2*chamfer, d2=d1+2*space, h=chamfer+eps);
  translate([0, 0, h-chamfer]) 
      cylinder(d1=d1+2*space, d2=d1+2*space+2*chamfer, h=chamfer+eps);
}