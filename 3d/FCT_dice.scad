
$fn=300;

d = 30;
r = d/2;
k = 0.96;
d2 = d * sqrt(2) * k;
depth =  1;
eps=0.01;

module inset_bottom(w=0.4, h=0.2, bounding_size = 200, eps=0.01) {
  if (w == 0 || h < 0) {
    children();
  } else {
    // The top part of the children without the inset layer.
    difference() {
      children();
      // TODO: use actual extended children projection instead
      // of a clube with arbitrary large x,y values.
      translate([0, 0, -9*h])
          cube([bounding_size, bounding_size, 20*h], center=true);
    }
    // The inset layer.
    linear_extrude(height=h+eps) offset(r = -w) projection(cut=true)
      children();
  }
}

module body() {
  intersection() {
     cube([d, d, d], center=true);
     sphere(d=d2); 
  }
}

module label(letter = "?") {
 translate([0, 0, r-depth]) linear_extrude(height = 5)
       text(text = letter, font = "Arial:style=Bold", valign="center", halign="center", size = 15);
}



module fb_base(x, y) {
  k=0.2;
  translate([0, -d*0.2, 0]) 
hull() {
translate([0, -18*k, 0]) cylinder(d=2, h=5);

translate([-32*k, 0, 0]) cylinder(d=2, h=5);
translate([32*k, 0, 0]) cylinder(d=2, h=5);
       translate([x*k, y*k, 0]) cylinder(d=2, h=5);
}
}

module fb() {
    fb_base(22, 60-6);

  translate([0, 0, depth/3]) 
    fb_base(0, 60);


  translate([0, 0, 2*depth/3]) 
    fb_base(-19, 60+13);
}

module ring(r, w) {
  h = 5;
  difference() {
    cylinder(r=r, h=h);
    translate([0, 0, -eps]) cylinder(r=r-w, h=h+2*eps);
  }
}

module target() {
  //ring(10, 2);
  //ring(6, 2);
  //cylinder(r=2, h=5);
  
   //ring(10, 2);
  ring(5, 2.5);
  ring(10, 2.5);
  //cylinder(r=2, h=5);
}

module main() {
  difference() {
    body();
    
    //label("X");
    
    rotate([0, 90, 0]) rotate([0, 0, 0]) label("F");
    rotate([0, 180, 0]) label("C");  
    rotate([0, 270, 0]) label("T");
    
    //rotate([90, 0, 0]) label("A");
    //rotate([-90, 0, 0]) label("B");
    
    rotate([90, 0, 0]) translate([0, 0, r-depth]) target();
    rotate([-90, 0, 0]) translate([0, 0, r-depth]) target();
    
    rotate([0, 0, 0]) translate([0, 0, r-depth]) fb();
    
    //rotate([-90, 0, 0]) translate([0, 0, r-depth]) fb();

  }
}

inset_bottom()
translate([0, 0, r-eps])
rotate([90, 0, 0])


main();

//fb();

//target();




