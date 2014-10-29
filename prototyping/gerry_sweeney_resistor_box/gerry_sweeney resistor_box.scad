// See OpenSCAD documentation at 
// http://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language
//
// A case for http://gerrysweeney.com/ resistor box.
// Use with four M2.5 x 8mm screws. Box is symetric. Tested with Makerfarm Prusa I3V
// 0.4mm Hexagon extruder, PLA 1.75, 0.3mm layer height, 0.3 infill (slicing by Slic3r 1.1.7).
//
// Public domain. Attribution not required. Provided AS IS.
//
// All dimensions are in millimeters.

// Display options
$fn=30;

// Board dimensions
//
// Board x dimension (as measured).
board_len = 116;  
// Board y dimension (as measured).
board_width = 40;  
// Board z dimension (nominal PCB height).
board_thickness = 1.6;  
// board edge to center of corner holes (as measured).
board_hole_distance = 3.58;  
// Required clearance below for resistors near the holes (as measured). 
// This is for two of the bottom resistors that are too close to the 
// corner hole.
resistor_z_clearance = 1.25; 
 
// Box dimensions
//
// Width of free space around the board.
board_margin = 0.5; 
// Width of box wall around the board.
wall_width = 2;  
// Radius of four rounded corners.
corner_radius = wall_width;  
// space between board and bottom of the box. Adjusted to match to screw length (8mm).
space_below_board = 5.4;  
// Height of wall above board top.
top_margin = 1;  
// Screw hole (for M2.5).
screw_hole_width = 2.2; 
// Visible width of support rail below the board. 
support_rail_width = 1.5;  
// x size of screw posts, measured from box outer surface.
support_post_x_len = 10;  
// x size of screw posts, measured from box outer surface.
support_post_y_len = 10;  

// Derived dimensions
//
// Distance from box outer surface to center of screw holes.
box_hole_distance = wall_width + board_margin + board_hole_distance;
// Total length of the box
box_len = 2*wall_width + 2*board_margin + board_len;
// Total width of the box.
box_width = 2*wall_width + 2*board_margin + board_width;
// Total height of the box.
box_height = wall_width + space_below_board + board_thickness + top_margin;
// Height of support rail from  outer bottom of the box.
support_rail_z_len = wall_width + space_below_board;
// Height of screw posts from outer bottom of the box.
support_post_z_len = support_rail_z_len - resistor_z_clearance;

// Report key dimensions.
echo(str("** Box dimensions: len=", box_len, ", width=", box_width, ", height=", box_height));
// This value should be slightly (e.g. 1mm) longer than the screw.
echo(str("** Screw max len: ", box_height - top_margin));
echo(str("** Support threading height: ", support_post_z_len));

// Defines a solid box of given origin and dimensions.
module solid_box(x, y, z, xlen, ylen, zlen) {
 translate([x, y, z]) 
 cube([xlen, ylen, zlen]); 
}

// Defines a solid box of given origin and dimension with 4 corners rounded.
module rounded_solid_box(x, y, z, xlen, ylen, zlen, radius) {
  // Create a solid box with four corners removed.
  translate([x, y, z]) {
    difference() {
      solid_box(0, 0, 0, xlen, ylen, zlen);
      // Remove square corners
      solid_box(0, 0, 0, radius, radius, zlen);
      solid_box(xlen-radius, 0, 0, radius, radius, zlen);
      solid_box(0, ylen-radius, 0, radius, radius, zlen);
      solid_box(xlen-radius, ylen-radius, 0, radius, radius, zlen);
    };

    // Add four rounded corners.
    translate([radius,radius,0]) cylinder(h = zlen, r = radius);
    translate([xlen-radius, radius, 0]) cylinder(h = zlen, r = radius);
    translate([radius, ylen-radius, 0]) cylinder(h = zlen, r = radius);
    translate([xlen-radius, ylen-radius, 0]) cylinder(h = zlen, r = radius);
  }
}

// Defines a scree hole at given x,y center.
module screw_hole(x, y) {
  translate([x, y, -1]) {
    cylinder(h=box_height+2, r=screw_hole_width/2);
  }
}

// Defines a support post (no hole) at given x,y (which are the minimal x,y origin of
// the post rather than the center).
module support_post(x, y) {
  rounded_solid_box(x, y, 0, support_post_x_len, support_post_y_len, support_post_z_len, corner_radius);
}

module sweeney_box() {
  difference() {
    union() {
      difference() {
        // Define the overall box.
        rounded_solid_box(0, 0, 0, box_len, box_width, box_height, corner_radius);
        // Remove material until the support rails.
        solid_box(wall_width, wall_width, support_rail_z_len, 
            box_len-2*wall_width, box_width-2*wall_width, box_height);
        // Remove material until the bottom.
        solid_box(wall_width + support_rail_width, wall_width + support_rail_width, wall_width, 
            box_len-2*(wall_width + support_rail_width), 
            box_width-2*(wall_width + support_rail_width), 
            box_height);
      }
      // Add support posts.
      support_post(0, 0);
      support_post(box_len - support_post_x_len, 0);
      support_post(0, box_width-support_post_y_len, 0);
      support_post(box_len - support_post_x_len, box_width - support_post_y_len);
    }

    // Remove material for screw holes.
    screw_hole(box_hole_distance, box_hole_distance);
    screw_hole(box_hole_distance, box_width-box_hole_distance);
    screw_hole(box_len-box_hole_distance, box_hole_distance);
    screw_hole(box_len-box_hole_distance, box_width-box_hole_distance);
  }
}

// The top object.
intersection() {
  sweeney_box();
  // Uncomment to print a small portion for testing.
  // solid_box(0, 0, 0, 20, 60, 60);
}




