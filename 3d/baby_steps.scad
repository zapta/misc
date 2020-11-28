// Babysteps pattern generator

pitch = 5;
line_width = 0.4;
height = 0.2;
line_length = 150;
num_rows = 30;
num_cols = 30;

// Compute translation to move [0, 0] to grid point
// [r, c].
function offset(r, c) = [
  c * pitch - line_width/2,  // x offset
  r * pitch - line_width/2   // y offset
];
  
// Vertical bar
module vbar(r1, r2, c) {
  min_row = min(r1, r2);
  max_row = max(r1, r2);
  n_rows = max_row - min_row;
  translate(offset(min_row, c))
    cube([line_width, pitch*n_rows+line_width, height]);
}

// Horizontal bar
module hbar(r, c1, c2) {
  min_col = min(c1, c2);
  max_col = max(c1, c2);
  n_cols = max_col - min_col;
  translate(offset(r, min_col))
    cube([pitch*n_cols+line_width, line_width, height]);
}

// Horizontal lines
for (r = [0:num_rows-1]) {
  hbar(r, 0, num_cols-1);
}

// Left hand connectors
for (r = [1:2:num_rows-2]) {
  vbar(r, r+1, 0);
}

// Right hand connectors
for (r = [0:2:num_rows-2]) {
  vbar(r, r+1, num_cols-1);
}

// Rear start guide
//vbar(0, num_rows, -1);
//hbar(0, -1, 0);

  