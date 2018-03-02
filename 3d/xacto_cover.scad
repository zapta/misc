$fn = 100;

eps1 = 0+0.01;
eps2 = 2 * eps1;

id = 12.5;
wall = 1.4;
od = id + 2*wall;
height = 30;

cut = 1;

// From thingiverse 109467
module pie(radius, angle, height, spin=0) {
    // Negative angles shift direction of rotation
    clockwise = (angle < 0) ? true : false;
    // Support angles < 0 and > 360
    normalized_angle = abs((angle % 360 != 0) ? angle % 360 : angle % 360 + 360);
    // Select rotation direction
    rotation = clockwise ? [0, 180 - normalized_angle] : [180, normalized_angle];
    // Render
    if (angle != 0) {
        rotate([0,0,spin]) linear_extrude(height=height)
            difference() {
                circle(radius);
                if (normalized_angle < 180) {
                    union() for(a = rotation)
                        rotate(a) translate([-radius, 0, 0]) square(radius * 2);
                }
                else if (normalized_angle != 360) {
                    intersection_for(a = rotation)
                        rotate(a) translate([-radius, 0, 0]) square(radius * 2);
                }
            }
    }
}


module body() {
difference() {
  cylinder(d=od, h=height);
  translate([0, 0, -eps1]) cylinder(d=id, h=height+eps2);
}
}


module cross_cut() {
translate([0, 0, 5+20-cut]) 
hull() {
cube([eps1, od, cut]); 
rotate([0, 0, 90]) cube([eps1, od, cut]); 
}
}

module cuts() {
translate([0, 0, 5]) cube([cut, od, 20]); 

rotate([0, 0, 90]) translate([0, 0, 5]) cube([cut, od, 20]); 
  cross_cut();
  
  cross_cut();
}



//cross_cut();

module clip() {
  translate([0, 0, -cut])
  difference() {
    intersection() {
      cylinder(d=od, h=height);
      #cross_cut();  
    }
    cylinder(d=id-2, h=height);
  }

}

module main() {
difference() {
body();
  cuts();
}
}

main();



//pie(od, 270, 2*dd+eps2);

dd = 1.3;

translate([0, 0, 5+20-2*dd-cut])
rotate([0, 0, 171])
difference() {
cylinder(d=od, h=dd*2);
translate([0, 0, -eps1]) cylinder(d1=id, d2=id-dd*2, h=dd+eps2);
translate([0, 0, dd]) cylinder(d2=id, d1=id-dd*2, h=dd+eps1);
  translate([0, 0, -eps1]) pie(od, 280, 2*dd+eps2);
  cylinder(d=id - 2, h=2*dd);
}
//#clip();

//rotate([0, -45, 0]) rotate([0, 0, 45]) cross_cut();

//difference() {
//cylinder(d=id, h=3);
//cylinder(d1=id, 
//}



