// Test first layer height. 
//
// Width of sides shoudl be close to 3mm. E.g. 3.1mm is good. 3.6 means 
// first layer is too smasshed.
// 
// A good first layer should be flat but the individual filament strands
// shoudl be visible.

l = 34;  // side length
w = 4;   // width
h = 1;   // height

eps = 0+0.01;

//module triangle(l, h)  {
//  hull() {
//    translate([0, l-eps, 0]) cube([eps, eps, h]);  
//    translate([l-eps, 0, 0])cube([eps, eps, h]);  
//    cube([eps, eps, h]);  
//  }
//}

module square(l, h)  {
  //hull() {
    translate([0, l-eps, 0]) cube([eps, eps, h]);  
    translate([l-eps, 0, 0])cube([eps, eps, h]);  
    translate([-l/2, -l/2, 0]) cube([l, l, h]);  
  //}
}

//difference() {
//  triangle(l, h);
//  translate([w, w, -eps]) triangle(l-w-w-w*sqrt(2), h+2*eps); 
//}
  
difference() {
 square(l, h);
 translate([0, 0, -eps]) square(l-2*w, h+2*eps); 
}
translate([l/2-2.5*w, l/2-w, 0]) square(w+eps, h);

