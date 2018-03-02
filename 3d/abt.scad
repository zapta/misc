// scale in simplify3d to 60mm height.

$fn=200;

// From thing:2219095. 
module inset_bottom(w=0.4, h=0.2, bounding_size = 200, eps=0.01) {
  if (w == 0 || h < 0) {
    children();
  } else {
    difference() {
      children();
      translate([0, 0, -9*h]) 
          cube([bounding_size, bounding_size, 20*h], center=true);
    }
    linear_extrude(height=h+eps) offset(r = -w) projection(cut=true)
      translate([0, 0, -h/2]) children();
  }
}

module letter(l) {
 rotate([90, 0, 0]) linear_extrude(height = 100) 
       text(text = l, font = "Arial:style=Bold", size = 60);
     }
     
module main() {
  rotate([90, 0, 0]) translate([-9.85, 23, 0]) 
  intersection() { 
    // A
    letter("A");
    // B
    translate([-20, -70, 0]) rotate([0, 0, 90]) letter("B");
  }
}

render(convexity = 2)
//inset_bottom(w=0.6, h=0.4)
translate([0, 0, 40.8]) rotate([0, 0, 180]) 
main();

