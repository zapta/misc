

$fn=64;

// Width at the opening, includes wall thickness.
width = 80;
// Length including wall thickness.
length = 90;
// Wall height at the closed end
height = 25;
// Wall height at the open end.
front_height = 10;
// Radius of the two corners at the closed end.
corner_radius=15;
// Wall thickness
wall_thickness = 2.5;
// Base thickness
base_thickness = 2.5;
// Reduced base thickness at the open end.
slope_height = 0.8;
// Length of base slope at the open end.
slope_length = 30;
// Inset first layer by this dimension (0 to disable). Helps prevnting
// 'elephant foot' syndrom.
first_layer_inset_width = 0.3;
// Height of first layer. Ignored if first_layer_inset_width is zero or negative.
first_layer_inset_height = 0.2;

eps1 = 0.01 + 0;  // hide on thingiverse customizer.
eps2 = 2*eps1;

// Operator to inset first layer to eliminate elephant foot.
// Children are assumed to be on the z=0 plane.
module inset_first_layer(w=0.4, h=0.2, eps=0.01) {
  if (w == 0 || h < 0) {
    children();
  } else {
    difference() {
      children();  
      // TODO: use actual extended children projection instead
      // of a clube with arbitrary large x,y values.
      cube([200, 200, h], center=true);
    }
    linear_extrude(height=h+eps) 
      offset(r = -w) 
        projection(cut=true) 
          children();  
  }
}

module block() {
  hull() {
    translate([length-corner_radius, width/2-corner_radius, 0]) 
        cylinder(r=corner_radius, h=height);
    translate([length-corner_radius, -(width/2-corner_radius), 0]) 
        cylinder(r=corner_radius, h=height);
    
    translate([0, -width/2, 0]) cube([eps1, width, front_height]);
  }
}

module hollow() {
  w = width - 2*wall_thickness;
  l = length - wall_thickness;
  r = corner_radius - wall_thickness;
  
  hull() {
    translate([l-r, w/2-r, base_thickness]) 
        cylinder(r=r, h=height);
    translate([l-r, -(w/2-r), base_thickness]) 
        cylinder(r=r, h=height);
    translate([-eps1, -w/2, base_thickness]) cube([eps1, w, height]);
  }
}

module slope() {
  w = width - 2*wall_thickness;
  hull() {
    translate([-eps1, -w/2, slope_height]) 
        cube([eps1, w, height]);
    translate([slope_length-eps1, -w/2, base_thickness+eps1]) 
        cube([eps1, w, height]);
  }
}

module main() {
  inset_first_layer(first_layer_inset_width, first_layer_inset_height) {
    difference() {
      block();
      hollow();
      slope();
    }
  }
}

main();
