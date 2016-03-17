$fn=64;

base_screw_space_x = 170;
base_screw_space_y = 39.35;

eps1=0.001;
eps2=2*eps1;

// Hole for a M3 metal insert, mcmaster part number 94180a333.
// h is the total depth for the screw hole. Already includes an
// extra eps1 at the opening side.
module m3_threaded_insert(h) {
  // Adding tweaks for compensate for my printer's tolerace.
  A = 4.7 + 0.3;
  B = 5.23 + 0.4;
  L = 6.4;
  D = 4.0;
  translate([0, 0, -eps1]) {
    // NOTE: diameter are compensated to actual print results.
    // May vary among printers.
    cylinder(d1=B, d2=A, h=eps1+L*2/3, $f2=32);
    cylinder(d=A, h=eps1+L, $f2=32);
    translate([0, 0, L-eps1]) cylinder(d=D, h=h+eps1-L, $f2=32);
  }
}

module screw_tab() {
  w=12;
  h1=8;
  h2=23;
  rotate([180, 0, 0]) 
  difference() {
    hull() {
      cylinder(d=w, h=h1);  
      translate([-6, -w/2, 0]) cube([eps1, w, h1]);
      translate([-6, -1, 0]) cube([eps1, 2, h2]);
    }
    translate([0, 0, -eps1]) m3_threaded_insert(h1+1);
  } 
}

//base_width

module rounded_cube(x, y, h, r1) {
  dx = x/2 - r1;
  dy = y/2 - r1;
  hull() {
    translate([-dx, -dy, 0]) cylinder(r=r1, h=h);
    translate([dx, -dy, 0]) cylinder(r=r1, h=h);
    translate([-dx, dy, 0]) cylinder(r=r1, h=h);
    translate([dx, dy, 0]) cylinder(r=r1, h=h);
  }
}

//module base_hole(x, y, h1) {
//  translate([x, y, -eps1]) cylinder(d=3, h=100, $fn=36);
//  translate([x, y, -eps1]) cylinder(d=8, h=h1,  $fn=36);
//  translate([x, y, h1+2]) cylinder(d=7, h=100,  $fn=36);
//}

//module base_plate() {
//  difference() {
//    rounded_cube(162, 68, 23, 5);
//    //#m3_threaded_insert(10);
//    
////    base_hole(-75, -27.6, 0);
////    base_hole(-75, 27.6, 0);
////    
////    base_hole(17.15, -27.6, 0);
////    base_hole(17.15, 27.6, 0);
////    
////    base_hole(71.5, -15.85, 3);
////    base_hole(71.5, 15.85, 3);
////    
////    translate([0, 0, -1]) #rounded_cube(135, 45, 20, 4);
//    //translate([-70, -22.5, -1]) cube([135, 45, 20]);
//  }
//}

module l_mount() {
  difference() {
    union() {
      hull() {
        translate([6-eps1, 0, 0]) cube([eps1, 4, 3]);
        translate([-8, 0, 0]) cube([eps1, 14, 3]);
      }
      translate([-9, 0, 0]) cube([15, 3, 23]);
    }
    // screw slot
    translate([0, -eps1, 9]) rotate([-90, 0, 0]) 
    #hull() {
      cylinder(d=3.4, h=3+eps2);
      translate([0, 5, 0]) cylinder(d=3.4, h=3+eps2);
    }
  }
}

module main() {
  //base_plate();
  rounded_cube(162, 68, 23, 5);
  dx = base_screw_space_x/2;
  dy = base_screw_space_y/2;
  translate([dx, dy, 23]) #screw_tab();
  translate([dx, -dy, 23]) screw_tab();
  translate([-dx, dy, 23]) rotate([0, 0, 180])  screw_tab();
  translate([-dx, -dy, 23]) rotate([0, 0, 180]) screw_tab();
  
   translate([162/2+7.0, -(68/2-23.8), 0]) l_mount();
  translate([-(162/2+7.0), -(68/2-23.8), 0]) mirror([1, 0, 0]) l_mount();
}



intersection() {
  main();
  //screw_tab();
  //translate([60, -50, -eps1]) cube([60, 100, 50]);
}







