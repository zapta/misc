// A 3D Toy

eps1 = 0.01;
eps2 = 2*eps1;

// Cube size.
cube_size = 25;

// Match this to elastic string's diameter.
slot_width = 2;

// Number of cube rows to print.
rows = 2;

// Number of cube columns to print
columns = 3;

// Space between cubes in the matrix. 
printing_space = 10;

pitch = cube_size + printing_space;

slot_depth = (cube_size + slot_width) / 2;

module sloted_cube() {
  difference() {
    cube([cube_size, cube_size, cube_size], center=true);

    translate([-slot_width/2, -cube_size/2 - eps1, -slot_width/2]) 
        cube([slot_width, cube_size+eps2, slot_depth+eps1]);

    translate([-cube_size/2 - eps1, -slot_width/2,  -cube_size/2-eps1]) 
        cube([cube_size+eps2, slot_width, slot_depth+eps1]);
  }
}


for (i = [1:columns]) {
  for (j = [1:rows]) {
    translate([i*pitch, j*pitch, 0]) sloted_cube();
  }
}