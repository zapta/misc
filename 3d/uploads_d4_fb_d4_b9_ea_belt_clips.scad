include <configuration.scad>;

// Belt parameters
belt_width = 6;                    // width of the belt, typically 6 (mm)
belt_thickness = 1.0 - 0.05;       // slightly less than actual belt thickness for compression fit (mm)           
belt_pitch = 2.0;                  // tooth pitch on the belt, 2 for GT2 (mm)
tooth_radius = 0.8;                // belt tooth radius, 0.8 for GT2 (mm)

// Overall clamp dimensions
clamp_width = 15;
clamp_length = 15;
clamp_base = 4;

path_height = belt_width + 1;
clamp_thickness = path_height+clamp_base;

$fn = 40;

clamp_inside_radius = clamp_width/2;
clamp_outside_radius = clamp_inside_radius+belt_thickness;
dTheta_inside = belt_pitch/clamp_inside_radius;
dTheta_outside = belt_pitch/clamp_outside_radius;
pi = 3.14159;

small = 0.01;  // avoid graphical artifacts with coincident faces

module tube(r1, r2, h) {
  difference() {
    cylinder(h=h,r=r2);
    cylinder(h=h,r=r1);
  }
}

module belt_cutout(clamp_radius, dTheta) {
  // Belt paths
  tube(r1=clamp_inside_radius,r2=clamp_outside_radius,h=path_height+small);
  for (theta = [0:dTheta:pi/2]) {
    translate([clamp_radius*cos(theta*180/pi),clamp_radius*sin(theta*180/pi),0]) cylinder(r=tooth_radius, h=path_height+small);
  }
}

module belt_clips() {
  difference() {
    cube([clamp_width,clamp_length,clamp_thickness]);
    translate([0,0,clamp_base]) {
      belt_cutout(clamp_inside_radius, dTheta_inside);
      translate([clamp_width,clamp_length,0]) rotate([0, 0, 180])
        belt_cutout(clamp_outside_radius, dTheta_outside);
    }
  };
}

belt_clips();
