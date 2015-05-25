// Experimental work in progress
//
// Print with material support.

$fn = 180;

eps = 0.01;
eps2 = 2*eps;

// Nozzle angle from the fan's normal. Possibe -> down.
nozzle_vertical_angle = 5;
// Nozzle angle from the fan's normal. Possitive -> toward the rear of the machine.
nozzle_horizontal_angle = 15;
nozzle_length = 38;
nozzle_base_od = 38.5;
nozzle_wall_thickness = 1.4;
// Nozzle ip external dimensions
tip_width = 12;
tip_height = 8;
tip_external_corner_radius = 2;
// Positive -> pointing down.
// From parallel to the fan's surface. Positive = clockwise from font view.
tip_vertical_angle = 30;
base_thickness = 2;
base_size = 40;
base_hole_spacing = 32;
base_corner_radius = 4.25;


tip_internal_corner_radius = max(eps, tip_external_corner_radius - nozzle_wall_thickness);

// d1 = inner diameter. d2 = outer diameter.
module donut(d1, d2) {
  rotate_extrude() 
translate([(d1+d2)/2/2, 0, 0]) 
circle(d = (d2-d1)/2);
}

// Centered at x,y=0.
module rounded_cube(x_len, y_len, h, r) {
  xr = x_len/2;
  yr = y_len/2;
  hull() {
    translate([-(xr-r), -(yr-r), 0]) cylinder(r=r, h=h);
    translate([-(xr-r), (yr-r), 0]) cylinder(r=r, h=h);
    translate([(xr-r), -(yr-r), 0]) cylinder(r=r, h=h);
    translate([(xr-r), , (yr-r)]) cylinder(r=r, h=h);
  } 
}

module nozzle() {
  //translate([nozzle_base_od/2 , nozzle_base_od/2, 0])
  h = nozzle_length * cos(nozzle_vertical_angle);
  x = nozzle_length * sin(nozzle_vertical_angle);
  y = nozzle_length * sin(nozzle_horizontal_angle);
  w2 = nozzle_wall_thickness * 2;
  
  //echo("Nozzle height", h);
  difference() {
    hull() {
      cylinder(d=nozzle_base_od, h=eps);
      translate([x, y, h-eps]) rotate([0, tip_vertical_angle, 0]) rounded_cube(tip_height, tip_width, eps, tip_external_corner_radius);
    }
    hull() {
      translate([0, 0, -eps]) cylinder(d=nozzle_base_od - w2, h=eps2);
      translate([x, y, h-eps]) rotate([0, tip_vertical_angle, 0]) rounded_cube(tip_height-w2, tip_width-w2, eps2, tip_internal_corner_radius);
   //   translate([0, 0, -eps]) cylinder(d=nozzle_base_od-2*nozzle_wall_thickness, h=eps);
   //   translate([40+nozzle_wall_thickness, 0+nozzle_wall_thickness, 50]) rounded_cube(7-2*nozzle_wall_thickness, 10-2*nozzle_wall_thickness, eps, 0.5);
    }
  }
 // rounded_cube(fan_diameter +2*5, fan_diameter + 2*5, 2+eps, 2);

}

module base() {
  h = base_thickness+eps2;
  l = base_hole_spacing/2;
  difference() {
    rounded_cube(base_size, base_size, base_thickness, base_corner_radius);
    translate(0, 0, -eps) union() {
      cylinder(d=nozzle_base_od-2*nozzle_wall_thickness, h=h);
      translate([-l, -l, 0]) cylinder(d=3, h=h);
      translate([-l, l, 0]) cylinder(d=3, h=h);
      translate([l, -l, 0]) cylinder(d=3, h=h);
      translate([l, l, 0]) cylinder(d=3, h=h);
    }
  }
}

module main() {
  difference() {
    union() {
      translate([0, 0, base_thickness - eps]) nozzle(); 
      base();
    }
      // translate([-100 - 6, -50, -eps])  cube([100, 100, 100]);
       translate([-40, 0, 6])  cube([40, 40, 7]);
     //cube{30, 50, 7]);

  }
  

  //rounded_cube(nozzle_base_od +2*5, nozzle_base_od + 2*5, 2+eps, 2);

}




//circle(d = (10)/2);



main();

   //

     //translate([30, -eps, -eps]) rotate([0, 0, -10]) cube([40, 80, 8]);


//main();

//nozzle();

//base();

// translate([x, 0, h-eps]) rounded_cube(7, 10, eps, 1);

//rounded_cube(7, 10, eps, 1);

   // rounded_cube([40, 40, eps, 3]);


//rounded_cube(6, 10, 5, 1);

