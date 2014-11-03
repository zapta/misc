$fn=360;

//inside_diameter = 3;
//outside_diameter_dia = 6;
//height = 5;
eps = 0.01;
eps2 = 2*eps;

module spacer(d1, d2, h) {
 difference() {
    cylinder(r=d1/2, h=h);
    translate([0, 0, -eps]) cylinder(r=d2/2, h=h+eps2);
 }
}

spacer(6, 3.2, 2);