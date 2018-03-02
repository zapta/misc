// scale in simplify3d to 60mm height.

$fn=200;



//module letter(l) {
translate([0, 0, 0.41]) rotate([90, 0, 0]) 
  linear_extrude(height = 30) 
       text(text = "JAVA", font = "Arial:style=Bold", size = 20);
       
translate([7, -30, 0]) #cube([12.4, 30, 2]);
//     }
     
//module body() {
//  rotate([90, 0, 0]) translate([-9.85, 23, 0]) intersection() { 
//    // A
//    letter("A");
//    // B
//    translate([-5, -25, 0]) rotate([0, 0, 90]) letter("B");
//  }
//}
//
//module main() {
// // difference() {
//    body();
//
////#translate([3.0, -5.3, 3.7]) rotate([0, 0, 180]) linear_extrude(height = 3) 
////       text(text = "ABT", font = "Arial Black:style=Bold", size = 1.8);
////  }
//}
//
//rotate([0, 0, 180]) 
//intersection() 
//{
//  main();
//  //translate([-20, -20, 0]) #cube([40, 40, 10]) ;
//}