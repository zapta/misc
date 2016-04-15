

$fn = 180;

total_width	= 25; //56;			// Width of the holder

indicator_hole_diameter	= 9.6+0.3;	

magnet_diameter = 6.3+0.3-0.05;			// Diameter of the magnet

magnet_length	= 6.3;//1;	// Height of the magnet

// Margin on both side of each rod slot.
rod_margin	= 5; 

// The thickness of the base plate.
base_height	 = 8;			

// Outer diameter of the indicator holder collar.
collar_height = 10;

// Total height of the part.
total_height = base_height + collar_height;

// The diameter of the rod slots. Includes margin for fitting.
rod_slot_diameter	= 8 + 0.3 ;	

// Distance bentwee the centerlines of the rods.
rod_centerline_space = 70;

// The thickness of the indicator holder collar wall. Should be thick enough
// to fit the threaded insert.
indicator_hole_wall = 7;

// The angle between the two threaded insert holes in the collar.
screw_angle = 100;  // angle between srews

// Outer diameter of the collar.
collar_outer_diameter	= indicator_hole_diameter + 2 * indicator_hole_wall; 

// Thickness of the collar support wall.
collar_support_thickness = 5;				

total_length 	= rod_centerline_space + rod_slot_diameter + 2*rod_margin;

indicator_hole_offset = 10;

eps1 = 0.02;
eps2 = 2*eps1;

// x,y are centered, z on on z=0;
module xy_centerd_cube(dx, dy, dz) {
  translate([-dx/2, -dy/2, 0]) cube([dx, dy, dz]);
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

module rod_cut(x) {
  translate([x, 0, collar_height]) rotate([90, 0, 0]) translate([0, 0, -(total_width/2+eps1)])
    cylinder(d=rod_slot_diameter, h=total_width+eps2);
}

module magnet_cut(x) {
  translate([x, 0, collar_height - rod_slot_diameter/2-magnet_length])
    cylinder(d=magnet_diameter, h=total_height);
}

// Generates the U-shape body.
module u_shape_body() {
  difference() {
    translate([0, 0, -base_height]) 
      xy_centerd_cube(total_length, total_width, total_height);
    
    xy_centerd_cube(total_length-2*(total_length-rod_centerline_space), 
      total_width+eps2, 
      collar_height+eps1);
  }
}

module main()  {
  d = collar_outer_diameter;
  r = d/2;
  alpha = screw_angle/2;
  difference() {
    union() {
      u_shape_body();
           translate([indicator_hole_offset, 0, -eps1]) 
        cylinder(d=d, h=collar_height+eps1);
      
      translate([indicator_hole_offset, -5/2, -eps1]) 
          cube([total_length/2-indicator_hole_offset- eps1, collar_support_thickness, collar_height+eps1]);
    }
    
    rod_cut(-rod_centerline_space/2);
    rod_cut(rod_centerline_space/2);
  
    magnet_cut(-rod_centerline_space/2);
    magnet_cut(rod_centerline_space/2);

    translate([indicator_hole_offset, 0, -total_height]) cylinder(d=indicator_hole_diameter, h=2*total_height);
    
    translate([indicator_hole_offset-r*cos(alpha), -r*sin(alpha), collar_height/2]) 
      rotate([0, 90, alpha]) translate([0, 0, -eps1]) m3_threaded_insert(r);
    
    translate([indicator_hole_offset-r*cos(alpha), r*sin(alpha), collar_height/2]) 
      rotate([0, 90, -alpha]) translate([0, 0, -eps1]) m3_threaded_insert(r);
  }
}

translate([0, 0, base_height]) main();


