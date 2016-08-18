

// The width of the hanger. Should fit the printer's slot width.
hanger_width = 47;  

// The height of the hanger tab. Should fit the printer's slot height.
inner_tab_height = 15;

// The width of the hanger slot. Should fit printer's wall thickness.
slot_thickness = 8;

// The external height of the hanger.
hanger_height = 35;

// The length of the rod. Should fit the spool inner width.
rod_length = 75;  

// The diameter of the rod.
rod_diameter = 25;

// The ehight of the top of the rod from the bottom of the hanger.
rod_height = 18;

// Raise the end of the rod by this angle. Use to compensate for 
// free play in the hanger slot.
rod_pitch_angle = 1.0;

// Thickness of the hanger's walls.
hanger_wall = 6;

// The height of the end stopper above the top of the rod.
stopper_margin = 6;

// The thickness of the stopper at the end of the rod.
stopper_thickness = 4;

/* [Hidden] */

// Faces per cylinder.
$fn=120;

hanger_thickness = slot_thickness + 2*hanger_wall;

stopper_diameter = rod_diameter+2*stopper_margin;

rod_radius = rod_diameter/2;

rod_center_z = -(rod_radius - rod_height);

// The size of the support at the corner between the rod and the hanger.
corner_size = 4;

// Adding to the internal tab a bump with diagonal edges for easier 
// alighment into the printer hole.
bump_size = 5;

// Small values to maintain manifold.
eps1 = 0.001;
eps2 = 2*eps1;


module bump() {
  translate([hanger_thickness-eps1, -hanger_width/2, hanger_height]) 
  rotate([0, 90, 0]) hull() {
    cube([inner_tab_height, hanger_width, eps1]);  
    translate([bump_size, bump_size, bump_size-eps1])
      cube([inner_tab_height - 2*bump_size, hanger_width-2*bump_size, eps1]);  
  }
}

module hanger() {
  translate([0, -hanger_width/2, 0]) difference() {
    cube([hanger_thickness,  hanger_width, hanger_height]);
    
    translate([hanger_wall, -eps1, -eps1]) 
      cube([slot_thickness, hanger_width+eps2, hanger_height-hanger_wall+eps1]);
    
    translate([hanger_wall + slot_thickness - eps1, -eps1, -eps1]) 

      cube([hanger_wall+eps2, hanger_width+eps2, hanger_height-inner_tab_height+eps1]);
  }
}

module rod() {
  intersection() {
    union() {
      // Rod.
      translate([0, 0, rod_center_z]) rotate([0, -90, 0]) 
          cylinder(d= rod_diameter, h=   rod_length);
      // Corner support.
      translate([0, 0, rod_center_z]) rotate([0, -90, 0]) 
          cylinder(d1=  rod_diameter+2*corner_size, d2=rod_diameter, h=corner_size); 
    }
    // Cut bottom.
    translate([-rod_length-eps1, -rod_diameter, -eps1]) 
        cube([rod_length+eps2, 2*rod_diameter, rod_height + corner_size+ eps1]);
  }
}

module stopper() {
  translate([-rod_length, 0, 0])  
  intersection() {
    translate([0, 0, rod_center_z]) rotate([0, -90, 0]) 
      cylinder(d=stopper_diameter, stopper_thickness);  
    
     translate([-stopper_thickness-eps1, -rod_diameter/2, 0]) 
       cube([stopper_thickness+eps2, rod_diameter, stopper_diameter]);
  }
}

module main() {
  hanger();
  bump();
  rotate([0, rod_pitch_angle, 0]) union() {
    translate([eps1, 0, 0]) rod();
    translate([eps2, 0, 0]) stopper();
  }
}

//main();

// Transformation to printing orientation. This keeps the 3D fibers 
// along the rod and the hanger for max strength. Make sure to 
// enable support material.
translate([0, 0, hanger_width/2]) rotate([-90, 0, 0]) main();

