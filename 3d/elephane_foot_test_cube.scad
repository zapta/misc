// Experimental first layers inset to eliminate elephan foot syndrom. 

// Adding '0' makes it hidden in Thingiverse customizer.
eps1 = 0.01 + 0;

// Cube dimension on the X axis.
cube_dx = 15;

// Cube dimension on the Y axis.
cube_dy = 15;

// Cube dimension on the Z axis.
cube_dz =  15;

// Printing layer height.
layer_height = 0.2;

// Inset levels for first layers, bottom layer first. Setup as many layers as you 
// like, and the rest will have an inset of 0.
insets = [0.3, 0.2, 0.1];

// Total height on insets layers. 
insets_height = len(insets) * layer_height;

// A centered cube of given dimensions with z elevation above the x,y plane.
module box(z, dx, dy, dz) {
  translate([-dx/2, -dy/2, z]) cube([dx, dy, dz+eps1]);
}

// The non inset part of the cube
box(insets_height, cube_dx, cube_dy, cube_dz-insets_height);

// The inset layers at the bottom.
for (i= [0:len(insets)-1]) {
  box(i*layer_height, cube_dx-2*insets[i], cube_dy-2*insets[i], layer_height);
}

