// TODO: set actual dimensions. 

$fn=16;

base_width1 = 68;
base_width2 = 48;
base_depth = 11.5;
base_height = 70;
wall = 4;
corner_radius = 2;
grab_width = 7.9;

lock_width = 12;
lock_height = 5;
lock_depth = 2.5;
lock_offset = 13.3;

total_width1 = base_width1 + 2*wall;
total_width2 = base_width2 + 2*wall;
total_depth = base_depth + 2*wall;
total_height = base_height + wall;

screw_hole_diameter = 4;

eps1 = 0.01;
eps2 = 2*eps1;

module gopro_coupler() {
  translate([0, -0.1, 12]) 
  rotate([-90, 0, 0])  {
  
    rotate([0, 0, 180])  import("gopro_tripple_head.stl", convexity=3);
    
    // support
    hull() {
      cube([19, 19, eps1], center=true);
      translate([0, 0, 2]) cube([14.5, 14.5, eps1], center=true);
    }
  }
}

module trapezoide(w1, w2, depth, h) {
  hull() {
    translate([-w1/2, 0, 0]) cube([w1, depth, eps1]); 
    translate([-w2/2, 0, base_height-eps1]) cube([w2, depth, eps1]);
  }
}

module screw_hole(z) {
  counter_sink_depth = 3;
  // Assuming 90 degree counter sink.
  d1 = screw_hole_diameter + 2*counter_sink_depth;
  translate([0, -wall-eps1, z]) rotate([-90, 0, 0]) {
    cylinder(d1=d1, d2=screw_hole_diameter, h=wall-1);
    cylinder(d=screw_hole_diameter, h=wall+eps2);
  }
}

module block() {
  r = corner_radius;
  dx1 = total_width1/2-r;
  dx2 = total_width2/2-r;
  
  hull() {
    // Bottom corners
    translate([dx1, -r, 0]) cylinder(r=r, h=eps1);
    translate([-dx1, -r, 0]) cylinder(r=r, h=eps1);
    translate([dx1, -(total_depth-r), 0]) cylinder(r=r, h=eps1);
    translate([-dx1, -(total_depth-r), 0]) cylinder(r=r, h=eps1);
    // Top corners
    translate([dx2, -r, total_height-r]) sphere(r=r);
    translate([-dx2, -r, total_height-r]) sphere(r=r);
    translate([dx2, -(total_depth-r), total_height-r]) sphere(r=r);
    translate([-dx2, -(total_depth-r), total_height-r]) sphere(r=r);

  }
}

module lock() {
  translate([-lock_width/2, -wall-eps1, lock_offset]) 
      cube([lock_width, lock_depth+eps1, lock_height]); 
}

module body() {
  difference() { 
    block();
    translate([0, -(base_depth+wall), -eps1]) 
      trapezoide(base_width1, base_width2, base_depth, base_height+eps1);
    
     translate([0, -(total_depth+eps1), -eps1]) 
      trapezoide(base_width1-2*grab_width, base_width2-2*grab_width, wall+eps2, base_height+eps1);
    
    lock();
    
    //screw_hole(24);
    //screw_hole(49);
  }
  gopro_coupler();

}

//body();



intersection() {
  body();
  translate([-12, -19, 0])  cube([25, 50, 23]);
}

k = 0.5;

translate([6.6, 0, 0]) cube([k, 18, 11]);
//translate([6, 0, 0]) cube([k, 18, 11]);
translate([4.9, 0, 0]) cube([k, 18, 11]);

translate([0.8, 0, 0]) cube([k, 18, 11]);
//translate([0, 0, 0]) cube([k, 18, 11]);
translate([-1, 0, 0]) cube([k, 18, 11]);

translate([-5.5, 0, 0]) cube([k, 18, 11]);
//translate([-6, 0, 0]) cube([k, 18, 11]);
translate([-7, 0, 0]) cube([k, 18, 11]);

translate([-7, 18-k, 0]) cube([14, k, 11]);
//translate([-7, 14, 0]) cube([14, k, 11]);
translate([-7, 10, 0]) cube([14, k, 11]);
//translate([-7, 5, 0]) cube([14, k, 11]);




//screw_hole();



