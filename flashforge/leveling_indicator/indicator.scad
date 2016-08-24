// Dial indicator holder for leveling Flashforge Creator Pro and similar
// 3D printers.
//
// The indicator is held in place by two M3 threaded metal heat inserts and screws.
// Inserts, screws and dial indicators are available on eBay from multiple sources.
// Insert the threaded inserts using a hot soldering iron, push it in slightly and 
// let the heat do the work.

// Smoothness of the rounded surfaces. 
$fn = 180;

// Total width of the part. Should be wide enough to allow collar
// diameter with metal threaded inserts.
total_width	= 25; 

// Inner diameter of the indicaotr holder collar. Tweak to have
// zero insertion force fit.
indicator_hole_diameter	= 8.7;	

// Diameter of the magnet hole. Tweak for a very very snug fit.
magnet_holes_diameter = 6.55;			

// Depth of the magnet hole, measured at the centerline of the rod slot. 
magnet_holes_depth	= 6.3;

// Margin on both side of each rod slot.
rod_margin	= 5; 

// The thickness of the base plate.
base_height	 = 8;			

// Height of the indicator holder collar, beyong the base plate.
collar_height = 10;

// Outer diameter of the collar.
collar_outer_diameter	= 23;

// Thickness of the collar support wall.
collar_support_thickness = 5;	

// The angle between the two threaded insert holes in the collar.
screw_angle = 100;  // angle between srews			

// Total height of the part.
total_height = base_height + collar_height;

// The diameter of the rod slots. Includes margin for fitting.
rod_slot_diameter	= 8.5;	

// Distance bentwee the centerlines of the rods. Tweak such that the 
// part fits nicely on top of the rods, even without magnets to force it
// in.
rod_centerline_space = 70.35;

// Total part length.
total_length 	= rod_centerline_space + rod_slot_diameter + 2*rod_margin;

// Offset of the indicator hole center from the center of the part. It is 
// offset slightly toward the front of the printer (away from the betl) so
// it doesn't go off the rear edge of the bed, hitting the small PCB 
// of the Flashforge Creator Pro. It's OK to set this to zero if
// you like.
indicator_hole_offset = 8;

// Threaded insert hole diameter multiplier. Allows to tweak the diameter.
threaded_insert_diameter_multiplier = 1.0;

// A small positive distance to maintain the maniforl consistency of the 
// generated model.
eps1 = 0.02;
eps2 = 2*eps1;

// x,y are centered, z on on z=0;
module xy_centerd_cube(dx, dy, dz) {
  translate([-dx/2, -dy/2, 0]) cube([dx, dy, dz]);
}

// Hole for a M3 metal insert, mcmaster part number 94180a333.
// h is the total depth for the screw hole. Already includes an
// extra eps1 at the opening side.
//
// TODO: move some of the const to customizeable parameters at the begining
// of the file.
module m3_threaded_insert(h) {
  // Adding tweaks for compensate for my printer's tolerace.
  A = threaded_insert_diameter_multiplier*(4.7 + 0.3);
  B = threaded_insert_diameter_multiplier*(5.23 + 0.4);
  L = 6.4;
  D = 4.0;
  translate([0, 0, -eps1]) {
    // NOTE: diameter are compensated to actual print results.
    // May vary among printers.
    cylinder(d1=B, d2=A, h=eps1+L*2/3, $f2=32);
    cylinder(d=A, h=eps1+L, $fn=32);
    translate([0, 0, L-eps1]) cylinder(d=D, h=h+eps1-L, $fn=32);
  }
}

// Produces a rod cut hole at a given offset from the center.
module rod_cut(x) {
  translate([x, 0, collar_height]) rotate([90, 0, 0]) translate([0, 0, -(total_width/2+eps1)])
    cylinder(d=rod_slot_diameter, h=total_width+eps2);
}

// Produces a magnet hole at a given offset from the center.
module magnet_cut(x) {
  translate([x, 0, collar_height - rod_slot_diameter/2-magnet_holes_depth])
    cylinder(d=magnet_holes_diameter, h=total_height);
}

// Produces the U-shape body.
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

// Produces the part at the printing position and orientation.
translate([-indicator_hole_offset, 0, base_height]) main();


