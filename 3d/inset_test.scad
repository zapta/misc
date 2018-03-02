eps = 0.01;
inset_width = 0.3;
inset_height = 0.2;

// An arbitrary part wich is placed at z=0.
module my_part() {
  difference() {
    translate([-5, -5, 0]) cube([10, 10, 5]);
    cube([6, 6, 20], center=true);
  }
}

// The arbitrary part with first layer inset.
module my_part_with_first_layer_inset() {
  difference() {
    my_part();  // <<====
    cube([100, 100, 2*inset_height], center=true);
  }
  linear_extrude(height=inset_height+eps) 
    offset(r = -inset_width) 
      projection(cut=true) 
        my_part();  // <<====
}

my_part_with_first_layer_inset();