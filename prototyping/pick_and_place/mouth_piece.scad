// TODO: this file require cleanup BADLY (formatting, consts, comments, etc).
// 
// Use with silicon aquarium air hose and a 3/8 fuel filter along the hose.

$fn=72;

eps=0.01;
eps2 = 2 * eps;

enable_cross_cut = 0;

bump_sphere_diameter = 15;
bump_support_height = 3;
bump_root_height = 9;
bump_stretch_factor = 1.5;
bump_root_diameter = 8;
base_diameter = 26;
base_height = 13;
connector_height = 10;
connector_diameter = 5.3;
air_path_diameter = 3.5;

// r1 is center radius of extrusion, r2 is donut thinkness).
module donut(r1, r2) {
  rotate_extrude() translate([r1, 0, 0]) circle(r = r2);
}

// id = inner diameter. r = support radius.
module support_ring(id, r) {
  //d = id - eps;
   difference() {
    cylinder(r=id/2+r, h=r);
    translate([0, 0, r]) donut(id/2+r, r);
    translate([0, 0, -eps]) cylinder(r=id/2, h=r+eps2);
  }
}

module bump() {
  scale([bump_stretch_factor, 1, 1])  difference() {
    union() {
      translate([0, 0, bump_root_height]) 
      hull() {
          translate([0, 0, bump_support_height + bump_sphere_diameter/2]) 
              sphere(d=bump_sphere_diameter);
          cylinder(d=bump_root_diameter, h=eps);
      }
      cylinder(d=bump_root_diameter, h=bump_root_height+eps);
    }
    cylinder(d=4, h=19);
    //translate([0, 0, 18]) sphere(d=10);
  }
}

module base() {
   sphere_diameter = 2*base_diameter;
   scale([1.2, 1, 1]) difference() {
   intersection() {
     translate([0, 0, -sphere_diameter/2 + base_height]) sphere(d=sphere_diameter);
     cylinder(d1=base_diameter-4, d2=base_diameter, h=base_height);
   }
    hull() {
      cylinder(d=18, h=eps);
      translate([0, 0, 6]) cylinder(d=20, h=eps);
      translate([0, 0, 10]) cylinder(d=connector_diameter+3, eps);
   }
  }
}

module body() {
 difference() {
   union() {
      translate([0, 0, base_height-2]) bump();  
      base();
    }
    //cylinder(d=15, h=10);
    // Cavity for connector
   

  }
}



module main() {
  rotate([0, 0, 90]) difference() {
    union() {
      body();
      cylinder(d=connector_diameter, h=connector_height);
      // connector holding ring.
      translate([0, 0, 1])
        donut(connector_diameter/2, 0.5);
      // Connector support.
      translate([0, 0, connector_height+eps]) rotate([180, 0, 0]) 
        support_ring(5, 2);
    }
    // Connector air path (narrow to fit connector OD).
    translate([0, 0, -1]) cylinder(d=air_path_diameter, h=28);
    
    // Release holes.
    translate([0, 50, 29.7]) rotate([90, 0, 0])
              cylinder(d=6, h=100); 
    // Cross cut
    if (enable_cross_cut) {
      cube([100, 100, 100]);
    }
  }
}

main();








