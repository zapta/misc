$fn=64;

chamfer = 1.5;

od = 12;
id = 8.1;
l = 14;

eps=0.05;
base = 2;


difference() {
  union() {
  translate([0, 0, chamfer]) cylinder(d=od, h=l-2*chamfer);
    cylinder(d1=od-2*chamfer, d2=od, h=chamfer+eps);  
    
    translate([0, 0, l-chamfer-eps]) cylinder(d1=od, d2=14-2*chamfer, h=chamfer+eps);  

  }
  
  translate([0, 0, base]) cylinder(d=id,h=l);
}

