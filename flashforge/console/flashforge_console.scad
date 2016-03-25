$fn=128;

eps1=0.01;
eps2=2*eps1;

base_screw_space_x = 170;
base_screw_space_y = 39.35;
base_thickness = 3;
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
  $fn=16;
  dx=base_screw_space_x/2;
  dy=base_screw_space_y/2;
  d=2.8;
  translate([-dx, -dy, -eps1]) cylinder(d=d, h=base_thickness+eps2);
  translate([dx, -dy, -eps1]) cylinder(d=d, h=base_thickness+eps2);
  translate([-dx, dy, -eps1]) cylinder(d=d, h=base_thickness+eps2);
  translate([dx, dy, -eps1]) cylinder(d=d, h=base_thickness+eps2);  
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
  $fn=24;
  dx=base_screw_space_x/2;
  dy=base_screw_space_y/2;
  // Ideally should be 11.9 but we make it longer and later chop
  // it to be flat with the front face for better printability on
  // Flashforge.
  top_extension = 30;
  hull() {
    base_tab(-dx, dy + top_extension, 0);  
    base_tab(dx, dy + top_extension, 180);  
    base_tab(-dx, -dy, 0); 
    base_tab(dx, -dy, 180); 
  }
}

module base_plate() {
  $fn=24;
  difference() {
    union() {
      base_tabs();
      rounded_cube(169.5, 73.3, base_thickness, 4);
    }
    base_holes();
  }
}

module base_slope() {
  hull() {
    x=162.5;
    y=68;
    r=4;
    h0=8;
    h1=55;
    
    rounded_cube(x, y, base_thickness, r);
    
    // Front panel rear points
    translate([-(x/2-r), (y/2-r), h0]) sphere(r=r);
    translate([(x/2-r), (y/2-r), h0]) sphere(r=r); 
    
    // Front paenl front point.
    translate([-(x/2-r), (y/2-r)-(h1-h0), h1]) sphere(r=r);
    translate([(x/2-r), (y/2-r)-(h1-h0), h1]) sphere(r=r);
    
    // Front panel front/botton points.
    translate([-(x/2-r), (y/2-r)-(h1-h0)-1, h1]) sphere(r=r);
    translate([(x/2-r), (y/2-r)-(h1-h0)-1, h1]) sphere(r=r);
  }
}

module base_hollow() {
  $fn=16;
  x=162.5-4;
  y=68-4;
  r=4-2;
  w=2;
  h0=8;
  h1=55;
  translate([0, 0, -eps2]) hull() {
    rounded_cube(x, y, 1, 3);
  
   // Front panel rear points
    translate([-(x/2-r), (y/2-r), h0]) sphere(r=r);
    translate([(x/2-r), (y/2-r), h0]) sphere(r=r); 
    
    // Front paenl front point.
    translate([-(x/2-r), (y/2-r)-(h1-h0)-1, h1]) sphere(r=r);
    translate([(x/2-r), (y/2-r)-(h1-h0)-1, h1]) sphere(r=r);
    
    // Front panel front/botton points.
    translate([-(x/2-r), (y/2-r)-(h1-h0)-1, h1]) sphere(r=r);
    translate([(x/2-r), (y/2-r)-(h1-h0)-1, h1]) sphere(r=r);
  } 
}

module main_pre_cut() {
  difference() {
    union() {
      base_plate();
      base_slope();
    }
    translate([0, 0, -eps1]) base_hollow();
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
  $fn=24;
  h1 = h+0.1;
  // @@@ TODO: change 5 to 0.
  translate([x, y, 0]) translate([0, 0, -(2-0.1)]) rotate([180, 0, 0]) difference() {
    cylinder(d=w, h=h1);  
    translate([0, 0, h1+eps1]) rotate([180, 0, 0]) m3_threaded_insert(h1+2);
  }
}

// Centered at (0, 0).
module lcd_cut() {
  translate([0, 0, -4])
   rounded_cube(81.5, 25+2, 5, 1.5);  
}

module lcd_inserts() {
  h = 8.5;
  w = 8;
  dx = 82/2;
  dy = 55/2;
  m3_threaded_post(dx, dy, w, h);
  m3_threaded_post(dx, -dy, w, h);
  m3_threaded_post(-dx, dy, w, h);
  m3_threaded_post(-dx, -dy, w, h);
}

module button_hole(x, y) {
  translate([x, y, -4]) cylinder(d=11.5, h=5);
}

// Center button at (0, 0).
module button_holes() {
  dx=15.5;
  dy=15.5;
  button_hole(0, 0);
  button_hole(0, dy);
  button_hole(0, -dy);
  button_hole(-dx, 0);
  button_hole(+dx, 0);
}

// Center button at (0, 0)
module button_inserts() {
  m3_threaded_post(21, 15.5, 10, 6); 
  m3_threaded_post(21, -15.5, 10, 6); 
  
  m3_threaded_post(-18.6, 23.05, 10, 6); 
  m3_threaded_post(-18.6, -23.05, 10, 6); 
}

// Tool access hole to the screws on the back of the faceplate.
module tool_access_hole(x, y) {
  $fn=32;
  translate([x, y, -12.5]) rotate([180, 0, 0]) cylinder(d=7, h=50);
}

// Rotate main_pre_cut such that the front panel is on the 
// z=0 plane.
module rotated_main_pre_cut() {
  //translate([0, -16.5, -30.869]) 
  rotate([ 45, 0, 0]) translate([0, -34, -9.7])
            main_pre_cut();  
}

module rotated_main_outline() {
  //translate([0, -16.5, -30.869]) 
  rotate([ 45, 0, 0]) translate([0, -34, -9.7]) {
      base_plate();
      base_slope();
  } 
}

module main() {
  lcd_center_x = -32.5 - 2.5;
  lcd_center_y = -29+1;
  
  buttons_center_x = lcd_center_x+85+2.5;
  buttons_center_y = lcd_center_y;
  
  difference() {
    union() {
      difference() {
        rotated_main_pre_cut();
        // Adjust the front surface to but just below  the x=0 plane.
        //translate([0, -16.5, -30.869]) rotate([ 45, 0, 0]) 
        //    main_pre_cut();
        // Chop the extra length of the base plate. This will make it flash 
        // with the front face for better printability.
        translate([-100, 0, 0]) cube([200, 30, 30]);
      }
      
      // We intersect the inserts with the outline to eliminate 
      // two small bumps at the top of the front panel.
      intersection() {
        //rotated_main_outline();
        translate([lcd_center_x, lcd_center_y, 0]) lcd_inserts();
      }
      
      translate([buttons_center_x, buttons_center_y, 0])       button_inserts();
    }
    
    #translate([-2, 0, +10]) rotate([0, -8, 0]) tool_access_hole(lcd_center_x-(82/2), lcd_center_y-(55/2));
    
    #tool_access_hole(lcd_center_x+(82/2), lcd_center_y-(55/2));
    
    // NOTE: slanted and shifted to have a better entry point that doesn't intersect
    // with the edge.
    # translate([0, 1, -3]) rotate([-8, 0, 0]) 
        tool_access_hole(buttons_center_x+21, buttons_center_y-15);
    
    #tool_access_hole(buttons_center_x-18.6, buttons_center_y-22.3);
    
    translate([lcd_center_x + 5.75, lcd_center_y, 0]) lcd_cut();
    
    translate([buttons_center_x, buttons_center_y, 0]) 
      button_holes();
  } 
}

//main();

//main_pre_cut();
// Rotating to printing position.
rotate([180, 0, 0]) main();

//rotate([45, 0, 0]) translate([0, -34, -9.7]) main_pre_cut();


