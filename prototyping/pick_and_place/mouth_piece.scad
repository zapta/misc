// TODO: this file require cleanup BADLY (formatting, consts, comments, etc).

$fn=72;

eps=0.01;
eps2 = 2 * eps;

enable_cross_cut = 1;

bump_sphere_diameter = 15;
bump_support_height = 1;
bump_root_height = 10;
bump_stretch_factor = 2;
bump_root_diameter = 8;
base_diameter = 30;
base_height = 13;
connector_height = 10;
connector_diameter = 5.3;
air_path_diameter = 3.5;

// r1 is center radius of extrusion, r2 is donut thinkness).
module donut(r1, r2) {
  rotate_extrude() translate([r1, 0, 0]) circle(r = r2);
}

module bump() {
   scale([bump_stretch_factor, 1, 1]) union() {
  translate([0, 0, bump_root_height]) 
    hull() {
      translate([0, 0, bump_support_height + bump_sphere_diameter/2]) sphere(d=bump_sphere_diameter);
      cylinder(d=bump_root_diameter, h=eps);
    }
  cylinder(d=bump_root_diameter, h=bump_root_height+eps);
  }
}

module base() {
   sphere_diameter = 2*base_diameter;
   intersection() {
     translate([0, 0, -sphere_diameter/2 + base_height]) sphere(d=sphere_diameter);
     cylinder(d=base_diameter, h=base_height);
   }
}

module body() {
 difference() {
   union() {
      translate([0, 0, base_height-2]) bump();  
      base();
    }
    cylinder(d=12, h=10);
  }
}



module main() {
  difference() {
    union() {
      body();
      cylinder(d=connector_diameter, h=connector_height);
      translate([0, 0, 1])
        donut(connector_diameter/2, 0.5);
      
    }
    // Connector air path (narrow to fit connector OD).
    translate([0, 0, -1]) cylinder(d=air_path_diameter, h=28);
    // Wider airpath above the connector.
    translate([0, 0, base_height]) cylinder(d=5, h=17);
    // Release holes.
    translate([-50, 0, 29.7]) rotate([0, 90, 0])
              cylinder(d=5, h=100); 
    // Cross cut
    if (enable_cross_cut) {
      cube([100, 100, 100]);
    }
  }
}

main();


