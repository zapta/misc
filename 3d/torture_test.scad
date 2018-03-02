
// Roundness
$fn=32;

bar_thickness = 5;

cube_length = 80;

base_thickness = 4;

// Base diameter as proporiton of cube_length.
base_scale = 1.1;

//base_radius = 60;

half_length = cube_length /2;

/* [Hidden] */

eps1 = 0.01;
eps2 = eps1*2;
steps = [-half_length, 0, half_length];
end_steps = [-half_length, half_length];

module bar() {
   rotate([0, 90, 0]) translate([0, 0, -half_length]) cylinder(d=bar_thickness, h=cube_length); 
}

module horiz_cube() {
  // Bars
  for (s1 = steps) {
    for (s2 = steps) {
      translate([0, s1, s2]) bar();
      translate([s1, s2, 0]) rotate([0, 90, 0]) bar();
      translate([s1, 0, s2]) rotate([0, 0, 90]) bar();
    }
  }
  
  // Spheres
  for (s1 = end_steps) {
    for (s2 = end_steps) {
      for (s3 = end_steps) {
        translate([s1, s2, s3]) sphere(d=bar_thickness);  
      }
    }
  }
}

// Cube titled on its corner.
module tilted_cube() {
      rotate([atan(sqrt(1/2)), 0, 0]) 
      rotate([0, -45, 0]) 
      translate([half_length, half_length, half_length]) 
  horiz_cube();
}

// Tilted and clipped cube
module clipped_cube() {
  dz = half_length/2/sin(90-atan(sqrt(1/2)));
  difference() {
    translate([0, 0, -dz])
      tilted_cube();

  translate([-cube_length, -cube_length, -2*cube_length]) 
    cube([2*cube_length, 2*cube_length, 2*cube_length]);
  }
}

module main() {
translate([0, 0, base_thickness - eps1]) clipped_cube();
  // Base
cylinder(d=cube_length*base_scale, h=base_thickness, $fn=4*$fn);
}

rotate([0, 0, 90]) main();
