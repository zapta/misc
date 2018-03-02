
$fn=128;
eps = 0.01;


module pull_tool() {
  d1 = 22;
  d2 = 16;
  l = 10;

  difference() {
    cylinder(d=d1, h=l); 
    translate([0, 0, -eps]) cylinder(d=d2, h=l+2*eps);  
  }
}

module push_tool() {
  d1 = 12;
  d2 = 5;
  l1 = 10;
  l2 = 3;

  difference() {
    cylinder(d=d1, h=l1); 
    translate([0, 0, l1-2]) cylinder(d=10, h=2+eps);
  }
  cylinder(d=d2, h=l1+l2); 


}


//pull_tool();

translate([20, 0, 0]) push_tool();
