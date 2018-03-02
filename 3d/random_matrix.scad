// Generate a matrix with random heights.

base_height = 2;
random_height = 5;
num_rows = 10;
num_cols = 10;
step_size = 2;

min_height = base_height;
max_height = base_height + random_height;

// Hack alert:
// The seed param of rands doesn't see to work so using this
// arbitrary string that invalidates the cache of thingiverse's 
// customizer and randomize the model.

// Type here arbitrary text to randomize the model.
rand_seed = "";

eps1 = 0.01 + 0;

module row() {
 for(col = [0 : num_cols-1]) {
    z = rands(min_height, max_height, 1)[0];
    translate([0, col*step_size, 0]) cube([step_size+eps1,step_size+eps1,z]);
  } 
}

for(row = [0 : num_rows-1]) {
     translate([row*step_size, 0, 0]) row();
  
}

