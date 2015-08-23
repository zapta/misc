
od1 = 15.1;  // for 10cc syringe
h1 = 50;

od2 = 10;
h2 = 4;

od3 = 20;
h3 = 3;

$fn=180;

phase = 0.5;

guide_len = h1+h2-2;
guide_diameter = 3.1;
guide_spacing = 10.5;

screw_hole_len = h1+h2-2;
screw_hole_diameter = 5.5;

nut_thickness = 3.9;
nut_diameter = 10.2;

eps1 = 0.001;
eps2 = 2*eps1;

module phased_cylinider(d, h, p1, p2) {
    cylinder(d1=d-p1, d2=d, h=p1);
    translate([0, 0, h-p2]) cylinder(d1=d, d2=d-p2, h=p2);
    translate([0, 0, p1-eps1]) cylinder(d=d, h=h-p1-p2+eps2);
}

module guides(h) {
translate([guide_spacing/2, 0, -eps1]) cylinder(d=guide_diameter, h=h+eps1);  
  translate([-guide_spacing/2, 0, -eps1]) cylinder(d=guide_diameter, h=h+eps1); 
  
  
}

module screw_hole() {
translate([0, 0, -eps1]) cylinder(d=screw_hole_diameter, h=screw_hole_len+eps1);  
}

module nut() {
  //track_width = guide_diameter + 1;
  
  rotate(30) translate([0, 0, -eps1]) 
      cylinder(d=nut_diameter, $fn=6, h=nut_thickness+eps1);  
  
  //translate([od1/2+eps1, -track_width/2, -eps1]) rotate([0, 0, 90]) cube([track_width, od1+eps2, nut_thickness]);
}

module body() {
  phased_cylinider(od1, h1, 2*phase, (od1-od2));  
  translate([0, 0, h1-eps1]) cylinder(d=od2, h=h2+eps1);  
  translate([0, 0, h1+h2-eps1]) phased_cylinider(od3, h3, phase, phase);
}

module main() {
  difference() {
    body();
    guides(guide_len);
    hull() { guides(nut_thickness); }
    nut();
    screw_hole();
  }
}

intersection() {
  main();
  translate([-50, -50, -eps1]) cube([100, 100, 10]);
  //translate([0, 0, -eps1]) cube([200, 200, 200]);
}

  


