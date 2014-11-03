// Makerfar Prusa I3V table corners for easy leveling adjustment.
//
// All dimensions are in mm.

// Number of segments per circle. Effects both OpenSCAD display and generated
// STL. Reduce during debugging for faster compilation.
$fn = 360;

// Critical parameters. Tweak if needed to fit your machine.
//
// The width between parallel edges of the nut hexagon hole. Increase 
// if the nut does not fit in the hole, decrease if the nut is too loose.
nut_hole_width = 5.8;

// The opening in degrees between the two vertical edges. Decrease if 
// too much sideway play. Increase if does not fit or too stressed.
opening_degrees = 147;

// The diameter of the inner cavity. Adjust if doesn't fit nicely the 
// diremeter of the hot bed's Mickey ears.
inner_diameter = 14.5;

// The height of the inner space. Adjust to match the hot bed's thickness (6mm
// on my printer) with an small extra margin. 
inner_height = 6.3;

// Other parameters.
bottom_height = 2;
top_height = 2;
side_wall_width = 2;
top_width = 4;

// Internal consts
//
// A small > 0 value. Used to have well defined relation between objects
// in substraction and union operations.
eps = 0.01;
eps2 = 2 * eps;

// Derived values.
total_height = bottom_height + inner_height + top_height;
inner_radius = inner_diameter/2;
outer_radius = inner_radius + side_wall_width;
stoppers_offset = outer_radius * cos(opening_degrees/2);

// Solid rectangular box.
// x,y,z is the location of min x,y,z corner.
module box(x, y, z, xlen, ylen, zlen) {
  translate([x, y, z]) {
    cube([xlen, ylen, zlen]);
  }
}

// Solid vertical hexagon 'cylinder'.
// x, y, z is the bottom center point.
// Width is between parallel vertical faces.
module hexagon(x, y, z, width, height) {
    boxWidth = width/1.75;

  translate([x, y, z + height/2]) {
    for (r = [-60, 0, 60]) rotate([0,0,r]) cube([boxWidth, width, height], true);
  }
}

// Solid vertical cylinder.
// x,y,z is the bottom center point.
module disc(x, y, z, radius, height) {
  translate([x, y, z]) {
    cylinder(r = radius, h = height);
  }
}

// A choped disc. offset is the distance of the chopping from the center
// of the disk (higher -> less chopping).
module partial_disc(x, y, z, radius, height, d) {
  difference() {
    disc(x, y, z, radius, height);
    translate([radius+eps+d, 0, (height+eps2)/2]) {
      cube([2 *radius, 2*(radius+eps), height+eps2], center=true);
    }
  }
}

module main_part() {
  difference() {
    union() {
      // Bottom disc.
      disc(0, 0, 0, inner_radius, bottom_height);
      // Half disk of side walls.
      partial_disc(0, 0, 0, outer_radius, total_height, stoppers_offset);
    }
    union() {
      // Create the inner space
      disc(0, 0, bottom_height, inner_radius, inner_height);
      // Chop the top.
      box(-outer_radius + top_width, 
          -outer_radius - eps, 
          bottom_height + inner_height - eps, 
          2*(outer_radius + eps), 
          2*(outer_radius + eps), 
          top_height + eps2);
      // Create the nut hole.
      hexagon(0, 0, -eps, nut_hole_width, bottom_height + eps2);
    }
  }
}

main_part();
