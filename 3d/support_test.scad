
base_length=20;
top_length=30;
post_width=8;
post_height=20;
base_thickness=1.5;
top_thickness=1.5;

// Base
translate([-base_length/2, -base_length/2, 0]) cube([base_length, base_length, base_thickness]);

// Post
translate([-post_width/2, -post_width/2, 0]) cube([post_width, post_width, base_thickness+post_height+top_thickness]);

// Top
for (i = [0:90:90]) { 
  rotate([0, 0, i])
    translate([-top_length/2, -post_width/2, base_thickness+post_height]) 
      cube([top_length, post_width, top_thickness]);
}



