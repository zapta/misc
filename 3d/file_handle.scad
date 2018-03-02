// File handle

// Based on http://www.thingiverse.com/thing:2031/
// Licenced under the GPLv3 by Vik Olliver, 19-Mar-2010
// http://www.thingiverse.com/thing:2031/

end_radius=10;
handle_max_rad=15;
handle_top_ht=25;
handle_lower_ht=70;
$fn=300;

//module fileShaft() {
//    rotate([0,90,0])
//    polyhedron(points=[[0,0,0], [0,5,0], [45,6.5,-0.5], [45,-1.5,-0.5],
//				           [45,-1.5,3.5], [45, 6.5, 3.5] , [0,5,3], [0,0,3]],
// 			      faces=[ [0,1,2,3], [4,5,6,7], [0,7,6,1], [2,5,4,3], [1,6,5,2], [0,3,4,7]]);
//}

module shaftHole() {
  hull() {
    cube([8, 4, 0.01], center=true);  
    translate([0, 0, 45]) cube([5, 3, 0.01], center=true); 
  } 
}


module file_handle() {
        difference() {
                // Handle body
                scale ([1,0.8,1]) union () {
                        translate ([0,0,handle_top_ht+handle_lower_ht]) sphere(end_radius,center=true);
                        translate ([0,0,handle_top_ht/2+handle_lower_ht+1]) cylinder(h=handle_top_ht+2,r1=handle_max_rad,r2=end_radius,center=true);
                        translate ([0,0,handle_lower_ht/2])cylinder(h=handle_lower_ht,r1=10,r2=handle_max_rad,center=true);
                        // Bolster
                        translate ([0,0,1]) scale ([1,1,0.4]) sphere(handle_max_rad,center=true);
                }
                // Flatten the bottom
                translate ([0,0,-15]) cube(30,center=true);
                // Hanging hole
                translate ([0,0,handle_lower_ht]) rotate ([90,0,0]) scale([1,3,1]) cylinder(h=50,r=4,center=true);
        }
}

difference() {
  file_handle();
  // File shaft cavity
  shaftHole();
 //translate([2,-1.5,44.8]) rotate([0,0,90]) fileShaft();
} 

//translate([0, 2, 0]) #hole();

