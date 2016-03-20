$fn=36;

eps1=0.001;
eps2=2*eps1;

base_screw_space_x = 170;
base_screw_space_y = 39.35;
base_thickness = 2;
base_corner_radius = 4;

module rounded_cube(x, y, h, r) {
  dx = x/2-r;
  dy = y/2-r;
  hull() {
    translate([-dx, -dy, 0]) cylinder(r=r, h=h);
    translate([dx, -dy, 0]) cylinder(r=r, h=h);
    translate([-dx, dy, 0]) cylinder(r=r, h=h);
    translate([dx, dy, 0]) cylinder(r=r, h=h);
  }
}

module base_holes() {
  dx=base_screw_space_x/2;
  dy=base_screw_space_y/2;
  translate([-dx, -dy, -eps1]) cylinder(d=2.5, h=base_thickness+eps2);
  translate([dx, -dy, -eps1]) cylinder(d=2.5, h=base_thickness+eps2);
  translate([-dx, dy, -eps1]) cylinder(d=2.5, h=base_thickness+eps2);
  translate([dx, dy, -eps1]) cylinder(d=2.5, h=base_thickness+eps2);  
}

module base_tab(x, y, dir) {
  translate([x, y, 0]) rotate([0, 0, dir])  {
    d2=10;  // outer
    l = 5;
    hull() {
      cylinder(d=d2, h= base_thickness);
      translate([l-1, -d2/2, 0]) cube([1, d2, base_thickness]);
    }
  }
}

module base_tabs() {
  dx=base_screw_space_x/2;
  dy=base_screw_space_y/2;
  hull() {
    base_tab(-dx, -dy, 0); 
    base_tab(-dx, dy + 11.9, 0);  
    base_tab(dx, -dy, 180); 
    base_tab(dx, dy + 11.9, 180);  
  }
}

module base_plate() {
  difference() {
    union() {
      base_tabs();
      rounded_cube(171.5, 73.3, 2, 4);
    }
    base_holes();
  }
}

module base_slop() {
  hull() {
    x=162.5;
    y=68;
    r=4;
    h=50;
    rounded_cube(x, y, base_thickness, r);
    
    translate([-(x/2-r), (y/2-r), 8]) sphere(r=r);
    translate([(x/2-r), (y/2-r), 8]) sphere(r=r); 
    
    translate([-(x/2-r), (y/2-r)-(h-8), h]) sphere(r=r);
    translate([(x/2-r), (y/2-r)-(h-8), h]) sphere(r=r);
    
    translate([-(x/2-r), -(y/2-r), h]) sphere(r=r);
    translate([(x/2-r), -(y/2-r), h]) sphere(r=r);
  }
}

module base_hollow() {
  x=162.5-4;
  y=68-4;
  r=4-2;
  w=2;
  h=50;
  translate([0, 0, -eps2]) hull() {
     rounded_cube(x, y, 1, 3);
    
   translate([-(x/2-r), (y/2-r), 8]) sphere(r=r);
    translate([(x/2-r), (y/2-r), 8]) sphere(r=r); 
    
    translate([-(x/2-r), (y/2-r)-(h-8), h]) sphere(r=r);
    translate([(x/2-r), (y/2-r)-(h-8), h]) sphere(r=r);
    
    translate([-(x/2-r), -(y/2-r), h]) sphere(r=r);
    translate([(x/2-r), -(y/2-r), h]) sphere(r=r);
  } 
}

module main_pre_cut() {
  // Adjust the front surface to but just below  the x=0 plane.
  translate([0, -17, -30.869]) rotate([ 45, 0, 0]) 
  difference() {
    union() {
      base_plate();
      base_slop();
    }
    base_hollow();
  }
}

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

// 2mm is added for the height for the front surface thinckness.
module m3_threaded_post(x, y, w, h) {
  h1 = h+1;
  // @@@ TODO: change 5 to 0.
  translate([x, y, 3]) translate([0, 0, -1]) rotate([180, 0, 0]) difference() {
    cylinder(d=w, h=h1);  
    translate([0, 0, h1+eps1]) rotate([180, 0, 0]) m3_threaded_insert(h1+2);
  }
}

module lcd_cut() {
 translate([0, 0, -4]) {
   rounded_cube(77+4, 25+4, 5, 3);  
   hull() {
    dx=32.9;;
    dy=6.8;
    r=4.5;
    translate([dx, -dy, 0]) rotate([45, 0, 45+0]) cylinder(r=r, h=15);
    translate([dx, dy, 0]) rotate([45, 0, 45+90]) cylinder(r=r, h=15);
    translate([-dx, dy, 0]) rotate([45, 0, 45+180]) cylinder(r=r, h=15);
    translate([-dx, -dy, 0]) rotate([45, 0, 45+270]) cylinder(r=r, h=15);
  }
 }
}

module main() {
  difference() {
    union() {
      main_pre_cut();
      m3_threaded_post(40, -30, 10, 5);
    }
    translate([-20, -30, 0]) lcd_cut();
  } 
}

main();

//difference() {
//  translate([-100, -100, -2]) cube([200, 200, 2]);
//  lcd_cut();
//  
//  
//  //translate([-100, -100, 0]) cube([200, 200, eps1]);
//  //translate([0, -17, -30.869]) rotate([ 45, 0, 0]) intersection() {
////    main();
//  //  translate([0, -100, -eps1]) cube([200, 200, 200]);  
//  //  translate([-100, 0, -eps1]) cube([200, 200, 200]);  
//  //}
//}

//lcd_cut();
//lcd_cut();

