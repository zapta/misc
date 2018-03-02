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

module letter1(l) {
 rotate([90, 0, 0]) linear_extrude(height = 100) 
       text(text = l, font = "PT Mono:style=Bold", size = 60);
       //text(text = l, font = "Comic Sans MS:style=Bold", size = 60);
       //text(text = l, font = "Courier:style=Bold", size = 60);
       //text(text = l, font = "Courier New:style=Bold", size = 60);
       //text(text = l, font = "Roboto Mono:style=Bold", size = 60);
}

module letter2(l) {
 rotate([90, 0, 0]) linear_extrude(height = 100) 
       //text(text = l, font = "PT Mono:style=Bold", size = 60);
       //text(text = l, font = "Comic Sans MS:style=Bold", size = 60);
       //text(text = l, font = "Courier:style=Bold", size = 60);
       //text(text = l, font = "Courier New:style=Bold", size = 60);
       //text(text = l, font = "Roboto Mono:style=Bold", size = 60);
  
       text(text = l, font = "Century Gothic:style=Bold", size = 58);
}
     
module main() {
  difference() {
    rotate([0, 0, 0]) translate([-9.85, 23, 0]) 
    intersection() { 
      // A
      letter1("I");
      // B
      translate([-20, -70, 0]) rotate([0, 0, 90]) letter2("M");
    }
    
    translate([-10.6, -20, -0.01]) cube([20, 20, 20]);
    
    translate([20.83, -20, -0.01]) cube([20, 20, 20]);

  }
}


intersection() {
render(convexity = 2)
inset_bottom(w=0.6, h=0.4)
//translate([0, 0, 40.8]) 
 
 
//rotate([-90, 0, 0])
main();

//translate([-0, -24, -1]) #cube([30, 30, 25]);
}

