// TODO: format the code below

eps = 0.01;

// Total out. Does not include the top rounder rim.
height = 27;  // doesn't include the rim

// Thickness of the bottom
bottom_thickness = 2.5;

// Measure orthogonal to the wall
wall_thickness = 2.5;

// Outer diameter at the bottom
bottom_od = 55;

// Outer diameter at the top
top_od = 75;

// d_height / d_radius
slope_tan = (height / ((top_od - bottom_od)/2));

slope_angle = atan(slope_tan);

// Radius of the bottom chamfer.
chamfer = 5;

// Code assumes chamfer > 0
actual_chamfer = max(chamfer, eps);

$fn_body = 256;

$fn_rim = 24;

$fn_chamfer=128;

// Wall thickness measured horizontally
horizontal_wall_thickness = wall_thickness / cos(90 - slope_angle);

module cavity() {
  extra_height = horizontal_wall_thickness;
  
  hull() {
  translate([0, 0, height + extra_height])
   cylinder(d=top_od-2*horizontal_wall_thickness
               +
              2*extra_height/slope_tan, h=eps, 
    $fn=$fn_body);
  
  
    rotate([0, 0, 360/$fn_body/2])
    translate([0, 0, bottom_thickness + actual_chamfer])
    rotate_extrude($fn=$fn_body)
      translate([bottom_od/2-horizontal_wall_thickness-actual_chamfer+actual_chamfer/slope_tan, 0, 0])
      circle(r = actual_chamfer, $fn=$fn_chamfer);
  }
}

module blank() {
    // External cylinder
    cylinder(d1=bottom_od, d2=top_od, h=height, $fn=$fn_body);
    rim();
}

module main() {
  difference() {
    blank();
    cavity();
   
  }
}


module rim() {
  r=horizontal_wall_thickness/2;

  translate([0, 0, height])
    difference() {
      rotate_extrude($fn=$fn_body)
        translate([top_od/2-r, 0, 0])
        circle(r = r, $fn=$fn_chamfer);
      
      translate([0, 0, -r-eps])
         cylinder(d=2*top_od, h=r);
    }
}

// A library module to inset the first layer to avoid 
// 'elephant foot'.
module inset_bottom(w=0.4, h=0.2, bounding_size = 200, eps=0.01) {
  if (w <= 0 || h < 0) {
    children();
  } else {
    // The top part of the children without the inset layer.
    difference() {
      children();
      // TODO: use actual extended children projection instead
      // of a clube with arbitrary large x,y values.
      translate([0, 0, -9*h]) 
          cube([bounding_size, bounding_size, 20*h], center=true);
    }
    // The inset layer.
    linear_extrude(height=h+eps) offset(r = -w) projection(cut=true)
      children();
  }
}

inset_bottom()
main();

//cavity();


