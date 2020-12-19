$fn=64;

height = 5;
width = 10;
thickness = 0.3;  // bridge

eps=0.01;

module step(i) {
  translate([0, 0, i*height]) difference() {
    union() {
      cylinder(d=width, h=height+eps);
      translate([0, -width/2, 0]) cube([25, width, height+eps]);
    }

    translate([20, -width/2-eps, 0]) rotate([0, 45, 0]) cube([2*height, width+2*eps, 2*height]);
      
    translate([4, -width/2-eps, -eps]) cube([2*height, width+2*eps, (height-thickness)/2+eps]);
      
    translate([4, -width/2-eps, (height+thickness)/2]) cube([2*height, width+2*eps, (height-thickness)/2+2*eps]);
      
  }
}

step(0);
step(1);
step(2);
step(3);






