// OpenScad L shape parmetric bracket for printing PCBs with solder
// paste stencils. Similar to the ones shown at 
// http://www.sunstone.com/pcb-products/pcb-solder-stencils/how-to-use 
// but it's parametric to you can adapt to your size and thickness.
// 
// Circle roundness. Higher is smoother but slower to compile.

// [ global ]

// Parts to print
num_parts = 2;  // [1:Single, 2:Pair]

// Nominal thickness of the bracket.
thickness = 1.6;  

// Inner length [mm] of cw hand.
inner_length1 = 50;
// Width [mm] of cw hand.
width1 = 30;

// Inner length [mm] of ccw hand.
inner_length2 = 20;
// Width [mm] of ccw hand.
width2 = 30;

// Radius of external corners [mm].
corner_radius=2;

// Radius of center hole [mm].
center_hole_radius = 2;

// Seperation [mm] between the two pieces.
pieces_seperation = 10;

// [ hidden ]

// Reduce to 18 for quick debugging.
$fn=180;

// Small distances. Used to make sure relationship between
// shapes are well defined. Do not effect dimensions of main object.
eps = 0.001;
eps2 = 2*eps;

// A simple L shape.
module l_shape(xl, yl, zl, xw, yw) {
  difference() {
    cube([yw+xl, xw+yl, zl]);
    translate([yw, xw, -eps]) 
        cube([xl+eps, yl+eps, zl+eps2]);
  }
}

// A L shape with rounded corners.
module rounded_l_shape(xl, yl, zl, xw, yw, r) {
  translate([r, r, 0]) minkowski() {
    l_shape(xl, yl, zl/2, xw-2*r, yw-2*r);
    cylinder(r=r, h=zl/2);
  }  
}

module one_part() {
 difference() {
    rounded_l_shape(inner_length1, inner_length2, thickness, 
        width1, width2, corner_radius);
    translate([width2, width1, 0]) 
        cylinder(r=center_hole_radius, h=thickness+eps);
  }
}

// A L shape with rounded corners and center release hole.
module main() {
  one_part();
  if (num_parts > 1) {
    translate([inner_length1+width2, 
               inner_length2+2*width1+pieces_seperation, 
               0]) rotate([0, 0, 180]) one_part();
  }
 
}

main();
