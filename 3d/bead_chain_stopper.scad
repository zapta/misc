
$fn=32 + 0;

eps=0+0.01;

// Outside diameter
d = 7;
// Total height
h = 9.5;
// Diameter of vertical center hole
hole_d = 1.3;
// Ball cavity diameter.
cavity_d = 3.8;
// Ball cavity external opening diameter.
guide_d = 3.2;
// Opening slot width
slot_w = 0.8;
ball_spacing = 4.2;

// Cavity and guide.
module cavity() {
  sphere(d=cavity_d); 
  hull() {
    sphere(d=guide_d); 
    translate([d, 0, 0]) sphere(d=guide_d); 
  }
}

// Main
rotate([0, 0, -30])
difference() {
  // Add
  cylinder(d=d, h=h);
  
  // Substract
  translate([0, 0, -eps]) cylinder(d=hole_d, h=h+2*eps);

  translate([0, 0, -eps]) 
  hull() {
    cylinder(d=slot_w, h=h+2*eps);
    translate([d, 0, 0]) cylinder(d=slot_w, h=h+2*eps);
  }
  
  translate([0, 0, h/2-ball_spacing/2])  cavity(); 
  translate([0, 0, h/2+ball_spacing/2])  cavity(); 
}

