// A handpiece for SMT vacuum pick and place tool.
// All dimensions in mm
// Print with high infill percentage (e.g. 50%) for better air tightness. 
// Material support not needed.

// Circles resolutions. Reduce for fast debugging.
$fn=76;

// Set to 0 or 1
release_hole_enabled = 1;

tip_bottom_diameter = 4.5;   
tip_length = 9;
tip_taper_percents = 6;
tip_wall_thickness = 0.8;

conn_bottom_diameter = 5.4;
conn_top_diameter = 5.3;
conn_length = 10;
conn_wall_thickness = 1;
conn_bump_size = 0.5;
conn_bump_offset = 1;

// Reduce tube length to let's say 5 for quick test prints.
tube_length = 110;
tube_diameter = 25;
tube_thickness = 2;
end_thickness = 3;
edge_radius = 2;

release_hole_diameter = 5;
release_hole_offset = 10;
release_chamber_length = 20;
inner_thickness = 2;
inner_tube_id = 4;

// For maintaing manifold.
eps = 0.001;
eps2 = 2*eps;

tip_top_diameter = tip_bottom_diameter * ((100 - tip_taper_percents)/100);
tip_hole_bottom_diameter = tip_bottom_diameter - 2*tip_wall_thickness;
tip_hole_top_diameter = tip_top_diameter - 2*tip_wall_thickness;

conn_hole_diameter = conn_top_diameter - 2*conn_wall_thickness;

// r1 is center radius of extrusion, r2 is donut thinkness).
module donut(r1, r2) {
  rotate_extrude() translate([r1, 0, 0]) circle(r = r2);
}

// r is the radius of the top edge.
module rounded_cylinder(d, h, r) {
  hull() {
     cylinder(d=d, h=h - r + eps);
     translate([0, 0, h-r]) intersection() {
       donut(d/2-r, r);
       // Pick the top half of the donut.
       cylinder(d=d, h=r);
     }
  }
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

// Part 1/3 - the nozzle tip.
// Total height = end_thickness + tip_length;
module tip() {
  difference() {
    union() {
      // base plate
      rounded_cylinder(tube_diameter, end_thickness + eps, edge_radius);
      // Hose cylinder
      translate([0, 0, end_thickness]) cylinder(
          d1=tip_bottom_diameter, d2=tip_top_diameter, h=tip_length); 
      translate([0, 0, end_thickness-eps]) 
          support_ring(tip_bottom_diameter - eps, 2);
    }
    // hole
    translate([0, 0, -eps]) 
        cylinder(
          d1=tip_hole_bottom_diameter, 
          d2=tip_hole_top_diameter, 
          h=tip_length + eps2 + end_thickness);
  }
}

// Part 2/3 - the hose connector.
// Total height = end_thickness + conn_length;
module connector() {
   translate([0, 0, end_thickness + conn_length]) rotate([0, 180, 0]) difference() {
    union() {
      //cylinder(d = 2*tube_diameter, h=end_thickness + conn_length - 0.03);
      difference() {
        // Overall body.
        rounded_cylinder(tube_diameter, conn_length + end_thickness, edge_radius);
        // Make outer shell.
        translate([0, 0, end_thickness]) cylinder(d=14, h=conn_length+eps);
      }
      // Connector hose
      translate([0, 0, end_thickness - eps]) 
          cylinder(d1=conn_bottom_diameter, d2=conn_top_diameter, h=conn_length + eps); 
      // Support ring
      translate([0, 0, end_thickness-eps2]) 
          support_ring(conn_bottom_diameter - eps, 2);
      // Bump
      translate([0, 0, end_thickness + conn_length - conn_bump_size - conn_bump_offset]) 
        donut(conn_top_diameter/2, conn_bump_size);
    }
    // Substract connector hole.
    translate([0, 0, -eps]) cylinder(d=conn_hole_diameter, h=end_thickness + conn_length + eps2); 
  }
}

// Part 3/3 - the holding tube connecting the tip and connector.
// Total length = tube_length
module tube() {
  union() {
    // Outer shell
    difference() {
      cylinder(d = tube_diameter, h=tube_length);
      translate([0, 0, -eps]) 
          cylinder(d = tube_diameter - 2*tube_thickness, h=tube_length + eps2);
      // Release hole. 
      if (release_hole_enabled) {
        translate([0, 0, tube_length-release_hole_offset]) rotate([-90, 0, 0]) 
            cylinder(d = release_hole_diameter, h=tube_diameter);
      }
    }
    // Inner tube to reduce parasitic volume.
    difference() {
      union() { 
        // Release chamber wall and shorter inner tube.
        if (release_hole_enabled) {
          translate([0, 0, tube_length-release_chamber_length-inner_thickness]) 
              cylinder(d=tube_diameter, h=inner_thickness);
          cylinder(d = inner_tube_id + 2*inner_thickness, 
              h=tube_length-release_chamber_length);
        }  else {
          // Full length inner tube. No release chamber.
          cylinder(d = inner_tube_id + 2*inner_thickness, h=tube_length);
        }
      }
      translate([0, 0, -eps]) 
          cylinder(d = 4, h=tube_length + eps2);
    }
  }
}

// The entire part.
module main_part() {
  union() {
    connector();
    translate([0, 0, end_thickness + conn_length - eps]) tube();
    translate([0, 0, end_thickness + conn_length +tube_length - eps2]) tip(); 
  }
}

// For debugging. Main part with cross section.
module main_part_cross_section() {
  total_length = 2*end_thickness + conn_length +tube_length + tip_length;
  difference() {
    main_part();
    translate([0, 0, -eps])  
        #cube(size= [tube_diameter + eps, 
             tube_diameter + eps,
             total_length]);
  }
}

main_part();

// For debugging
//main_part_cross_section();

//translate([0, 0, tube_length-10]) rotate([-90, 0, 0]) cylinder(d = 5, h=tube_diameter);

//tip();
//connector();
//tube();
