// A handpiece for SMT vacuum pick and place tool.
// All dimensions in mm.
// Use large number of top horizongal shell layers (e.g. 10) for better air tightness.
// Material support not needed.
//
// TODO: file needs cleanup badly (formatting, consts, spelling, etc).

// Use 72 for production, 12 for debugging (faster)
$fn=72;

// 0 or 1
enable_release_hole = 0;

// 0 or 1. For debugging.
enable_cross_cut = 0;

// Designed in inkspace, exported as dxf using the BetterDxf
// inkspace extension. Defines the contour f the handle.
contour_file_name = "handle_contour.dxf";

eps = 0.01;
eps2 = 2*eps;

// Offset to match the imported DXF profile to our Y coordinates.
dxf_import_y_offset = 197.02;
// The total height of the imported DXF profile.
body_height = 116.01;
// Bounds the diameter of the imported DXF profile after rotation.
body_max_diameter = 16;

release_hole_offset = 14;
// Starting with a small hole. Drill a larger one if needed.
release_hole_diameter = 2;

tip_bottom_diameter = 4.5;
tip_height = 9;
tip_taper_percents = 6;
tip_hole_diameter = 2;
tip_top_diameter = tip_bottom_diameter * ((100 - tip_taper_percents)/100);
echo("tip_top_diameter:", tip_top_diameter);

conn_diameter = 5.3;
conn_length = 10;
// Defines the ID of the connector.
conn_wall_thickness = 1;
// For better retention of the hose.
conn_bump_size = 0.5;
conn_bump_offset = 1;
// Provides clearance for the outer surface of the hose.
conn_clearance_diameter = 10;

conn_hole_diameter = conn_diameter - 2*conn_wall_thickness;

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

// Release chamber. Having cone top to reduce the hangover
// effect. The chamber doesn't occupy the entire handle to 
// reduce the vaccum 'capacitance' (volume).
module chamber() {
  hull() {
    cylinder(d=9, h=15);
    cylinder(d=tip_hole_diameter, h=21);
  }
}

// Tip for the niddle, without the through hole.
module tip() {
  //difference() {
    union() {
       cylinder(
          d1=tip_bottom_diameter, d2=tip_top_diameter, h=tip_height);
       support_ring(tip_bottom_diameter - eps, 2);
    }
}

// Hoze connector. Without the through hole.
module connector() {
   translate([0, 0,  conn_length]) rotate([0, 180, 0]) 
      union() {
          cylinder(d=conn_diameter, h=conn_length);
      // Support ring
      translate([0, 0, 0])
          support_ring(conn_diameter - eps, 2);
      // Bump
      translate([0, 0, conn_length - conn_bump_size - conn_bump_offset])
        donut(conn_diameter/2, conn_bump_size);
    }
}

// Construct the raw body from the DXF profile. Z range = [0, 
// dxf_handle_height].
module body() {
  difference() {
    rotate_extrude(convexity = 10) 
      translate([0, dxf_import_y_offset, 0]) 
      import(file = contour_file_name);
     // Chamber
      translate([0, 0, 92]) chamber();
    if (enable_release_hole) {
      // Release hole
      translate([0, 0, body_height - release_hole_offset]) rotate([90, 0, -90]) 
        cylinder(d=release_hole_diameter, body_max_diameter/2);
    }
   
  
    // Through hole above to the chamber (narower for mechanicla strength).
    // Connector space
    translate([0, 0, -eps])
            cylinder(d=conn_clearance_diameter, h=conn_length);
  }
}
// The entire part.
module main() {
  // Rotating for good view angle of the hole on thigiverse.
  rotate([0, 0, -205]) difference() {
    union() {
      body();
      translate([0, 0, body_height-eps]) tip(); 
      translate([0, 0, eps]) connector(); 
    }
    // Thin through hole throuout the body and the tip. 
    translate([0, 0, -eps]) cylinder(d=tip_hole_diameter, body_height + tip_height + eps2);
      // Wide through hole below chamber
    translate([0, 0, -eps]) cylinder(d=conn_hole_diameter, body_height -20 + eps2);

    if (enable_cross_cut) {
      translate([-body_max_diameter/2, 0, -eps]) 
        cube([body_max_diameter+eps2, 
              body_max_diameter+eps2, 
              body_height+tip_height + eps2]);
    }
  }
}


main();

