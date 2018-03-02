// Replacement top plate for Flashforge Creator Pro dual extruder.
//
// Note: openscad doesn't preview this model correctly, use the
// Render button (slow) to view accurate results.

$fn=60;

base_thickness = 7.5;

eps1=0.001;
eps2=2*eps1;

tube_hole_diameter  = 6.2 + 0.5;
screw_hole_diameter = 3.0 + 0.5;

clamp_hole_diameter = 11;
clamp_offset = 32;
clamp_height = 24;

module solid_funnel(d1, d2, h, k, n) {
  h0 = h - eps1;
  for (i =[0:n-1]) {
    h_1 = h0 * i / n; 
    h_2 = h0 * (i+1) / n;

    offset_1 = (d2 - d1) * pow(h_1,k)/pow(h0,k);
    offset_2 = (d2 - d1) * pow(h_2,k)/pow(h0,k);

    d_1 = d1 + 2*offset_1;
    d_2 = d1 + 2*offset_2;
    // Extending vertically by eps1 to maintain manifold with next slice.
    translate([0, 0, h_1]) cylinder(d1=d_1, d2=d_2, h=eps1+h/n); 
  }
}

module hollow_funnel(od1, od2, id1, id2, h, k1, k2) {
  difference() {
    union() {
      solid_funnel(od1, od2, h, k2, floor($fn/4));
      // chamfer
      cylinder(d1=od1+2*2, d2=od1-eps1, h=2);
    }
    translate([0, 0, -eps1]) solid_funnel(id1, id2, h+eps2, k1, floor($fn/4));
  }
}

module tube_guide() {
  k1 = 4;
  k2 = 2;
  funnel_height = 11;
  top_hole_diameter = 11;
  bottom_wall = 4;
  top_wall = 3;

  hollow_funnel(tube_hole_diameter+2*bottom_wall, top_hole_diameter+2*top_wall, tube_hole_diameter, top_hole_diameter, funnel_height, k1, k2);
}

// 2D points of the right side of the base polygon.
points = [
   [-eps1,0],
   [23.4, 0],
   [28.4, 5],
   [28.4, 31.40],
   [37.75, 41.47],
   [37.75, 54.9],
//--
   //[32.6, 54.9],
   //[32.6, 45.11],
  // [14.23, 45.11],
   //[14.23, 54.9],
   [-eps1, 54.9],
   //[5, 41.60],
   //[4, clamp_offset],
   [-eps1, clamp_offset],
 ];
 
 module slab() {
   render(convexity = 2) 
   linear_extrude(height = base_thickness)  {
     polygon(points);
     rotate([0, 180, 0]) polygon(points);
   }
 }
 
  module extruder_slot() {
    mirror([1, 0, 0]) translate([14.23, 45.11, -eps1]) cube([18.5, 10, base_thickness+eps2]);
 }

 module wires_slot() {
 w = clamp_hole_diameter;
 y2 = 54.9;
   hull() {
      translate([0, clamp_offset, -eps1]) cylinder(d=w, h=base_thickness+eps2);
      translate([0, y2+eps1, -eps1]) cylinder(d=w, h=base_thickness+eps2);
   }
 }
 
 module clamp() {
  difference() {
    union() {
      // Main cylinder.
      cylinder(d=18, h=clamp_height);
      // Top ring.
      translate([0, 0, clamp_height-1]) rotate_extrude() translate([8.8, 0, 0]) circle(r = 1);
      // Chamfer
      cylinder(d1=18+2*2, d2=14-eps1, h=4);
    }
    
    translate([0, 0, clamp_height-4])  solid_funnel(clamp_hole_diameter, clamp_hole_diameter+2.0, 4+eps1, 2, $fn/4);
 
    // 180 deg cut
    translate([-15, 0, -eps1]) cube([30, 20, clamp_height+3]);
  }
}

 module base_hole(x, y, d) {
   h = 50;
   chamfer=0.4;
   translate([x, y, 0]) {
     cylinder(d=d, h=h);
     translate([0, 0, -eps1]) cylinder(d1=d+2*chamfer, d2=d-eps2, chamfer);
   }
 }
 
 module base() {
   difference() {
     union () {
       slab();  
       translate([0, clamp_offset, base_thickness-eps1]) clamp();
     }
     base_hole(0, 8.9, screw_hole_diameter);
     base_hole(0, 18.9, screw_hole_diameter);
     //#base_hole(17.0, 11.75, tube_hole_diameter);
     base_hole(-17.0, 11.75, tube_hole_diameter);
     base_hole(0, clamp_offset, clamp_hole_diameter);
     
     wires_slot();
     extruder_slot();
   }
 }
 
 module screw_spacer() {
   difference() {
     cylinder(d=6, h=8);
     base_hole(0, 0, screw_hole_diameter);
   }
 }
 
 module main() {
   base();
   //translate([17.0, 11.75, base_thickness-eps1]) tube_guide();
   translate([-17.0, 11.75, base_thickness-eps1]) tube_guide(); 
   
   translate([0, -10, 0]) screw_spacer();
 }
 
intersection() {
  main();
  // For debugging
  //#translate([-15, 20, 0]) cube([30, 18, 40]);
  //#translate([-12, 20, -eps1]) cube([22, 30, 40]);  
}
 
