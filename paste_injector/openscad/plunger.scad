
od1 = 15.1;  // for 10cc syringe
h1 = 37.5;

od2 = 8;
h2 = 1;

od3 = 12.8;
h3 = 1.5;

$fn=180;

phase = 0.5;

guide_len = h1+h2-2;
guide_diameter = 3.1;
guide_spacing = 10.5;

screw_hole_len = h1+h2;
screw_hole_diameter = 5.5;

nut_thickness = 3.3;
nut_diameter = 10.2;
nut_offset = 2;

eps1 = 0.001;
eps2 = 2*eps1;

total_height = h1 + h2 + h3;
echo("*** total height: ", total_height);

module phased_cylinder(d, h, p1, s1, p2, s2) {
    cylinder(d1=d-2*p1, d2=d, h=s1*p1);
  
    translate([0, 0, s1*p1-eps1]) cylinder(d=d, h=h-s1*p1-s2*p2+eps2);
  
    translate([0, 0, h-s2*p2]) cylinder(d1=d, d2=d-2*p2, h=s2*p2);
}

module guides(h) {
  translate([guide_spacing/2, 0, -eps1]) cylinder(d=guide_diameter, h=h+eps1);  
  translate([-guide_spacing/2, 0, -eps1]) cylinder(d=guide_diameter, h=h+eps1);  
}

module screw_hole() {
  translate([0, 0, -eps1]) cylinder(d=screw_hole_diameter, h=screw_hole_len+eps1);  
}

module nut() {
  rotate(30) translate([0, 0, nut_offset]) 
      cylinder(d=nut_diameter, $fn=6, h=nut_thickness+eps1);  
}

module body() {
  phased_cylinder(od1, h1, phase, 1, (od1-od2)/2, 2);  
  translate([0, 0, h1-eps1]) cylinder(d=od2, h=h2+eps1);  
  translate([0, 0, h1+h2-eps1]) phased_cylinder(od3, h3, phase/2, 1, phase/2, 1);
}

module main() {
  difference() {
    body();
    guides(guide_len);
    //hull() { guides(nut_thickness); }
    nut();
    screw_hole();
  }
}

//difference() {
//  intersection() {
//    main();
//    //translate([-50, -50, -eps1]) cube([100, 100, 10]);
//  }
//  translate([0, 0, -eps1]) cube([200, 200, 200]);
//}


main();

//phased_cylinder(10, 20, 3, 3);

//body();//
//translate([0, 0, 3]) cube([1, 1, 7]);

//nut();

  


