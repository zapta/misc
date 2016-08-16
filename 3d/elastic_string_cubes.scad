// A 3D Toy

// TODO: simplify. The current script is convoluted for historic reasons
// (adding the insets and end pieces)

eps1 = 0.01;
eps2 = 2*eps1;

// Cube size.
cube_size = 15;

// Match this to elastic string's diameter.
slot_width = 2.5;

// Roughly the string diameter when streched.
slot_overlap =2;

// Number of cube rows to print.
rows = 3;

// Number of cube columns to print
columns = 2;

// How many of the pieces are end pieces.
end_pieces = 2;

// Space between cubes in the matrix. 
printing_space = 10;

// Center to center printing distance.
pitch = cube_size + printing_space;

// The depth of the slotes.
slot_depth = (cube_size + slot_overlap) / 2;

// Height of printing layer. 
layer_height = 0.2;

// Inset levels per layer. Bottom layer first. Use to compensate for
// elephant-foot artifact.
bottom_insets = [0.3, 0.2, 0.1];

// Inset levels per layer. Top layer first. Use to compenstate for 
// printer artifacts.
top_insets = [0.2, 0.1];

// Total height of bottom inset layers
bottom_insets_height = len(bottom_insets) * layer_height;

// Total height of top inset layers
top_insets_height = len(top_insets) * layer_height;

// Diameter of end piece knot hole as a fraction of the cube size.
knot_hole_diameter_factor = 0.6;

// Depth of end piece knot hole as a fraction of the cube size.
knot_hole_depth_factor = 0.35;

// How smooth to compute circles.
$fn = 32;

// For non end piece and for bottom of end piece. 
module inset_small_base(layer_insets) {
  dx = cube_size;
  dy = (cube_size - slot_width)/2;
  for (i = [0 : len(layer_insets) - 1]) { 
    inset = layer_insets[i];
    dx_inset = dx - 2*inset;
    dy_inset = dy - 2*inset;
    translate([0, (cube_size + slot_width)/4, -cube_size/2]) 
      translate([-dx_inset/2, -dy_inset/2, i*layer_height]) 
        cube([dx_inset, dy_inset, layer_height+eps1]);
  }
}

// For end piece. 
module inset_large_base(layer_insets) {
  dx = cube_size;
  dy = cube_size;
  for (i = [0 : len(layer_insets) - 1]) { 
    inset = layer_insets[i];
    dx_inset = dx - 2*inset;
    dy_inset = dy - 2*inset;
    translate([0, 0, -cube_size/2]) 
    translate([-dx_inset/2, -dy_inset/2, i*layer_height]) 
        cube([dx_inset, dy_inset, layer_height+eps1]);
  }
}

module inset_bases(is_end_piece) {
  inset_small_base(bottom_insets);
  mirror([0, 1, 0]) inset_small_base(bottom_insets);
  rotate([0, 0, 90]) {
    mirror([0, 0, 1]) union() {
      if (is_end_piece) {
        inset_large_base(top_insets);
      } else {
        inset_small_base(top_insets);
        mirror([0, 1, 0]) inset_small_base(top_insets);
      }
    }
  }
}

// The cube body without the insets.
module cube_body() {
  total_insets_height = bottom_insets_height + top_insets_height;
  diff_insets_height = bottom_insets_height - top_insets_height;
  translate([0, 0, diff_insets_height/2])
    cube([cube_size, cube_size, cube_size-total_insets_height], center=true);
}

// Hole for end piece knot.
module end_piece_hole(){
  diameter = cube_size * knot_hole_diameter_factor; 
  depth = cube_size * knot_hole_depth_factor;
  // Throue hole
  translate([0, 0, -eps1]) cylinder(d=slot_width, h=cube_size/2+eps2);  
  // Knote hole 
  translate([0, 0, cube_size/2-depth]) cylinder(d=diameter, h=depth+eps1);
  // Inset the knot hole
  for (i = [0 : len(top_insets) - 1]) { 
    translate([0, 0, cube_size/2 - (i+1)*layer_height])
    cylinder(d=diameter+2*top_insets[i], h=layer_height+eps1);
  }
}

module one_piece(is_end_piece) {
  difference() {
    union() {
      cube_body();   
      inset_bases(is_end_piece);
    }

    // Bottom slot.
    translate([-cube_size/2 - eps1, -slot_width/2,  - cube_size/2-eps1]) 
        cube([cube_size+eps2, slot_width, slot_depth+eps1]);
   
    if (is_end_piece) {
      end_piece_hole();
    } else {
      // Top slot
      translate([-slot_width/2, -cube_size/2 - eps1, -slot_overlap/2]) 
        cube([slot_width, cube_size+eps2, slot_depth+eps1]);
    }
  }
}

module main() {
  for (i = [0:columns-1]) {
    for (j = [0:rows-1]) {
      is_end_piece = ((i*columns + j) < end_pieces);
      translate([i*pitch, j*pitch, 0]) one_piece(is_end_piece);
    }
  }
}



main();

//end_piece_hole();

