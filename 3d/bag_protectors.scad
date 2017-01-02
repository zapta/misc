$fn=64;
eps1=0.01;
eps2=2*eps1;
d1=6;
d2=10;
height=12;
hole_margin=3;
hole_diameter=2.8+0.5;

//difference() {
//  //hull() {
//    translate([0, 0, height-d2/2]) sphere(d=d2);
//    cylinder(d=d1, h=1);
//  }
//  translate([0, 0, -eps1]) cylinder(d=hole_diameter, h=height-hole_margin+eps1);
//  
//  cylinder(d=1, h=height+eps1);
//}

module torus(r1, r2)
{
rotate_extrude() translate([r1,0,0]) circle(r2);
}

module holder() {
 // translate([12/2, 0, 0]) rotate([0, -90, 0]) 
difference() {
cylinder(d=8, h=12);
translate([0, 0, 12/2]) rotate_extrude() translate([9,0,0]) circle(12/2);

  //torus(9, 12/2);
    translate([0, 0, -eps1]) cylinder(d=hole_diameter, h=12-hole_margin+eps1);
  
  // Chamfer
translate([0, 0, -eps1]) cylinder(d1=hole_diameter+1, d2=hole_diameter, h=1/2+eps1);

}
}

//hull() {
holder();


////translate([0, 0, -10]) holder();
//


