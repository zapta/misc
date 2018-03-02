// scale in simplify3d to 60mm height.

$fn=200;



module letter(l) {
 rotate([90, 0, 0]) linear_extrude(height = 30) 
       text(text = l, font = "Arial:style=Bold", size = 20);
     }
     
module body() {
  rotate([90, 0, 0]) translate([-9.85, 23, 0]) intersection() { 
    // A
    letter("R");
    // B
    translate([-5, -25, 0]) rotate([0, 0, 90]) letter("C");
  }
}

module main() {
 // difference() {
    body();

//#translate([3.0, -5.3, 3.7]) rotate([0, 0, 180]) linear_extrude(height = 3) 
//       text(text = "ABT", font = "Arial Black:style=Bold", size = 1.8);
//  }
}

rotate([0, 0, 180]) 
intersection() 
{
  main();
  //translate([-20, -20, 0]) #cube([40, 40, 10]) ;
}