// A 3D Toy

eps1 = 0.01;
eps2 = 2*eps1;

// Cube size.
cube_size = 15;

// Match this to elastic string's diameter.
slot_width = 2.5;

// Roughly the string diameter when streched.
slot_overlap =2;

// Number of cube rows to print.
rows = 2;

// Number of cube columns to print
columns = 2;

// Space between cubes in the matrix. 
printing_space = 10;

pitch = cube_size + printing_space;

slot_depth = (cube_size + slot_overlap) / 2;

layer_height = 0.2;

// Inset levels per layer. Bottom layer first.
bottom_insets = [0.4, 0.3, 0.2, 0.1];

top_insets = [0.2, 0.1, 0.0, 0.0];

insets_height = len(bottom_insets) * layer_height;

// At height insets_height + eps1. 
module inset_base(layer_insets) {
  dx = cube_size;
  dy = (cube_size - slot_width)/2;
  for (i = [0 : len(layer_insets) - 1]) { 
    inset = layer_insets[i];
    dx_inset = dx - 2*inset;
    dy_inset = dy - 2*inset;
    translate([0, (cube_size + slot_width)/4, -cube_size/2]) 
    translate([-dx_inset/2, -dy_inset/2, i*layer_height]) 
        #cube([dx_inset, dy_inset, layer_height+eps1]);
  }
}

module inset_bases() {
  inset_base(bottom_insets);
  mirror([0, 1, 0]) inset_base(bottom_insets);
  rotate([0, 0, 90]) {
    union() {
      mirror([0, 0, 1]) inset_base(top_insets);
      mirror([0, 0, 1]) mirror([0, 1, 0]) inset_base(top_insets);
    }
  }
}

module cube_body() {
  cube([cube_size, cube_size, cube_size-2*insets_height], center=true);
}

module sloted_cube() {
  difference() {
    union() {
      cube_body();   
      inset_bases();
    }

    translate([-slot_width/2, -cube_size/2 - eps1, -slot_overlap/2]) 
        cube([slot_width, cube_size+eps2, slot_depth+eps1]);

    translate([-cube_size/2 - eps1, -slot_width/2,  - cube_size/2-eps1]) 
        cube([cube_size+eps2, slot_width, slot_depth+eps1]);
  }
}

module main() {
  for (i = [1:columns]) {
    for (j = [1:rows]) {
      translate([i*pitch, j*pitch, 0]) sloted_cube();
    }
  }
}

//sloted_cube();
//
//
//inset_bases();

main();

//cube([15, 15, 10]);
//cube_body();
