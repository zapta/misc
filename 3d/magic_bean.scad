 
// Pause mid way, drop the metal ball, and continue printing.
// Print vertically with support material from bed. Raft optional.

debug = 0;  // [0, 1]

// Inner diameter. Make this the diameter of the ball with 
// a small clearance for free movement.
inner_diameter = 12;

// The thickness of the wall.
wall_thickness = 0.8;  

outer_diameter = inner_diameter + 2 * wall_thickness;

// Control the distance between the hemispheres as a fraction
// of inner_diameter. Higher values mean longer capsule.
length_ratio = 1.0; 

// Vertial center to center length
c2c = inner_diameter * length_ratio;

// Roundness resolution (higher = smoother and slower to render)
$fn=120;  

// Bounding box dimensions
large = 2*(outer_diameter + c2c);

module solid_capsule(d) {
    translate([0, 0, -c2c/2]) cylinder(d=d, h=c2c);
    translate([0, 0, -c2c/2]) sphere(d=d);
    translate([0, 0, c2c/2]) sphere(d=d);
}

module main() {
  difference() {
    solid_capsule(outer_diameter);
    solid_capsule(inner_diameter);
  }
}

module cross_cut() {
  rotate([0, 0, 245]) 
  difference() {
    main();
    translate([0, 0, -large/2]) cube([large, large, large]);
  }
}


if (debug == 1) {
  cross_cut();
  //translate([0, 0, -c2c/2]) #sphere(d=0.95*inner_diameter);
} else {
    main();
}

