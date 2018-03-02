
$fn=64;

id=11.6;

difference() {
  union() {
    // Chamfer bottom 
    cylinder(d1=14.2, d2=15, h=0.5+0.01);
    // Base 
    translate([0, 0, 0.5]) cylinder(d=15, h=1);
    // Top plug 
    cylinder(d=id, h=1.5+10);
  }
  // Hollow hole
  translate([0, 0, 0.6]) #cylinder(d1=9, d2=8.9, h=11);
  
  for (i = [0:120:270]) { 
    rotate([0, 0, i]) translate([0, -1, 1.5+2]) cube([30, 2, 15]);
  }
}

