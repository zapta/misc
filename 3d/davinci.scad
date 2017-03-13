// zpos stop at 17.4mm.

//$fn=40;
$fn=160;

eps1 = 0.01;
eps2 = 2*eps1;

cut_horiz_clearance = 0.4;

wall_width = 4;

bar_width = 16;
bar_height = 20;
cut_width = bar_width + 2*cut_horiz_clearance;

rod_length = 35;
rod_clearance = 1;
rod_top_clearance = 0.2;


// Hole length of one side. Should be longer than 
// rod length.
hole_length = rod_length+rod_clearance;
hole_diameter = 4+0.6;

bar_length = cut_width + 2*hole_length + 2*wall_width;


dent_diameter = hole_diameter;
dent_space = 3;

ring_width = 8;
ring_inner_diameter = 44;

// Operator to inset first layer to eliminate elephant foot.
// Children are assumed to be on the z=0 plane.
module inset_first_layer(w=0.4, h=0.2, eps=0.01) {
  if (w == 0 || h < 0) {
    children();
  } else {
    difference() {
      children();
      // TODO: use actual extended children projection instead
      // of a clube with arbitrary large x,y values.
      cube([200, 200, h], center=true);
    }
    linear_extrude(height=h+eps)
      offset(r = -w)
        projection(cut=true)
          children();
  }
}

module box(dx, dy, dz) {
  translate([-dx/2, -dy/2, 0]) cube([dx, dy, dz]);
}

module hole() {
l = 2*hole_length+cut_width;
translate([0, 0, bar_height*3/4]) union() {
hull() {
  translate([-l/2, 0, 0]) rotate([0, 90, 0]) cylinder(d=hole_diameter, h=l);
  translate([0, 0, hole_diameter/2]) box(l, hole_diameter, rod_top_clearance);
  
  
}

translate([(l-hole_diameter)/2, 0, -hole_diameter/2]) box(5, 1.5*hole_diameter, hole_diameter+rod_top_clearance);

translate([-(l-hole_diameter)/2, 0, -hole_diameter/2]) box(5, 1.5*hole_diameter, hole_diameter+rod_top_clearance);

}


}

module dent() {
  translate([0, dent_space/2, bar_height/4]) rotate([-90, 0, 0])  cylinder(d=dent_diameter, h=bar_width/2);
}

module bar() {
  difference() {
    box(bar_length, bar_width, bar_height);
    translate([0, 0, bar_height/2]) 
        box(cut_width, bar_width+eps1, bar_height);
    hole();
    dent();
    mirror([0, 1, 0]) dent();
  }
}

module ring()  {
  translate([0, 0, ring_width/2]) 
  rotate_extrude()
  translate([(ring_inner_diameter+ring_width)/2, 0])
  circle(d = ring_width);
}

module main() {
    inset_first_layer() {
      bar();
    }
    inset_first_layer() {
      translate([0, -30, 0]) bar();
    }  
    translate([0, 50, 0]) ring();
}

main();

 

