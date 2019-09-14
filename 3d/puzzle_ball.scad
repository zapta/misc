$fn=128;

difference() {
  sphere(d=22);

      translate([0, 0, -12]) cylinder(d=5, h=25);
      translate([0, 0, 9]) cylinder(d1=2.9, d2=7, h=2.01);
  
  translate([0, 0, -14]) {
   cylinder(d=9, h=20);
 translate([0, 0, 19.9]) cylinder(d1=9, d2=4, h=2.5);
  }
}




