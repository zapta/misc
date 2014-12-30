// OpenScad L shape parmetric bracket for printing PCBs with solder
// paste stencils. Similar to the ones shown at 
// http://www.sunstone.com/pcb-products/pcb-solder-stencils/how-to-use 
// but it's parametric to you can adapt to your size and thickness.
// 
// Circle roundness. Higher is smoother but slower to compile.
$fn=72;

// Adjust match the thickness of the PCB. The actual printed thickness
// depends on your slicer and printer.
//thickness = 0.8;
//thickness = 1.0;
thickness = 0.88;  // results in 1.1mm thickness with my printing process.
//thickness = 1.6;
//thickness = 2.0;

// The inner lengths and width of the arm along the x axis.
xlength = 50;
xwidth = 30;

// The inner lengths and width of first arm along the y axis
ylength = 30;
ywidth = 30;

// The radius of the rounded corners.
corner_radius=2;

// The raius of the corner clearance hole.
hole_radius = 2;

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

// A L shape with rounded corners and center release hole.
module main_part() {
  difference() {
    rounded_l_shape(xlength, ylength, thickness, 
        xwidth, ywidth, corner_radius);
    translate([ywidth, xwidth, 0]) 
        cylinder(r=hole_radius, h=thickness+eps);
  }
}

main_part();
