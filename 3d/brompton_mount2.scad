

eps1 = 0.01;
eps2 = 2*eps1;

$fn = 256;


module half_clamp(isTop) {
intersection() {

difference() {
  
  translate([-60/2, 0, -10]) rotate([0, 90, 0]) cylinder(d=80, h=60);
translate([-60/2-eps1, 0, 0]) rotate([0, 90, 0]) cylinder(d=40, h=60+eps2);
  
  for (i = [-1, 1]) {
    if (isTop) {
      translate([i*15, 0, 0]) { 
        cylinder(d=10, h=70);
        translate([0, 0, 26]) #cylinder(d=15, h=70);
      }
    }
    
    for (j = [-1, 1]) {
      fn = isTop ? $fn : 6;
      translate([i*20, j*28, -eps1]) cylinder(d=4, h=50);
      translate([i*20, j*28, 10]) cylinder(d=10, h=50, $fn=fn); 
    }
  }
}

translate([-60/2-eps1, -70/2, 0]) cube([60+eps2, 70, 80+eps1]);

}

}


half_clamp(true);
//half_clamp(false);