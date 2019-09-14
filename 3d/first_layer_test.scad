// Test first layer height. 
//
// Width of sides shoudl be close to 3mm. E.g. 3.1mm is good. 3.6 means 
// first layer is too smasshed.
// 
// A good first layer should be flat but the individual filament strands
// shoudl be visible.


l = 35;  // side length
w = 5;   // width
h = 1;   // height

eps = 0+0.01;


module square(l, h)  { 
    translate([-l/2, -l/2, 0]) cube([l, l, h]);  
}

  
difference() {
 square(l, h);
 translate([0, 0, -eps]) square(l-2*w, h+2*eps); 
}
translate([l/2-2.5*w, l/2-w, 0]) square(w+eps, h);

