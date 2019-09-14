
length = 80;

jaw_inner_length = 28;
hanger_inner_length = 11;

jaw_thickness = 6; //8;
hanger_thickness = 6;

height = hanger_thickness + jaw_inner_length;

vertical_vslot_depth = 0; //1.5;
horizontal_vslot_depth = 0; //1.5;

horizontal_vlost_offset = 7.5;

parts_spacing = 30;

grid_depth =  0.5;
grid_line_width = 0.8;
// Nominal pitch of grid lines. Automatically fined tuned 
// to actual dimensions.
grid_pitch = 3;

eps=0+0.001;


module vslot() {
  translate([-length/2-eps, 0])
  rotate([135, 0, 0])
    cube([length+2*eps, 2*jaw_thickness, 2*jaw_thickness]);
}

module bulk() {
  translate([-length/2, 0, 0])
  cube([length, hanger_inner_length + jaw_thickness, hanger_thickness]);

  translate([-length/2, 0, 0])
  cube([length, jaw_thickness, jaw_inner_length + hanger_thickness]);
}

module grid_line() {
  translate([-eps, -jaw_thickness, -grid_line_width/2])
cube([length+height+2*eps, jaw_thickness, grid_line_width]);
}

// Generate grid. We optimize the grid pitch and angle to 
// improve the partial grid on the boundary. The goal is to have
// grid lines going through all four corners such that we 
// maximize the side of the partial diamonds to be exacly half
// of a full diamond.
module grid() {
  // Desired pitch measured horizontal/vertical
  nominal_step = grid_pitch * sqrt(2);
  
  // Optimize horzontal step
  horiz_m = round(length / nominal_step);
  horiz_step = length / horiz_m;
 
  // Optimize vertical step
  vert_m = round(height / nominal_step);
  vert_step = height / vert_m;
 
  // Compute grid angle
  grid_angle = atan(vert_step / horiz_step);
  
  // Generate grid
  n = round(length / horiz_step);
  for (j = [0:1]) {
    mirror([j, 0, 0]) 
    for (i = [-vert_m:horiz_m]) {
      translate([i*horiz_step-length/2, grid_depth, 0]) {
        rotate([0, -grid_angle, 0]) grid_line();
      }
    }
  }
}

module main1() {
  difference() {
    bulk();

   if (horizontal_vslot_depth > 0) {
      translate([0, horizontal_vslot_depth, 
                 hanger_thickness + horizontal_vlost_offset]) 
      vslot();
    }
    
    // Vertical slot
    if (vertical_vslot_depth > 0) {
      translate([0, vertical_vslot_depth, 0]) 
      rotate([0, 90, 0])
      vslot();
    }
    
    if (grid_depth > 0) {
      grid();
    }
  }
}

// Inset first layer to avoid 'elephane foot' syndrom.
module inset_bottom(w=0.4, h=0.2, bounding_size = 200, eps=0.01) {
  if (w <= 0 || h < 0) {
    children();
  } else {
    difference() {
      children();
      translate([0, 0, -9*h]) 
          cube([bounding_size, bounding_size, 20*h], center=true);
    }
    linear_extrude(height=h+eps) offset(r = -w) projection(cut=true)
      children();
  }
}

inset_bottom()
main1();