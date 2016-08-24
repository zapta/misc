// A spool hanger for Flash Forge Creator Pro 3D printer.
//
// Using 1/4" threaded rod and 4 x R4ZZ bearings.

// TODO: cleanup the code
// TODO: make sure all dimensions are derived from consts
// TODO: covert to metric shaft rod and bearings.

// The width of the hanger. Should fit the printer's slot width.
hanger_width = 47;  

// The height of the hanger tab. Should fit the printer's slot height.
inner_tab_height = 15;

// The width of the hanger slot. Should fit printer's wall thickness.
slot_thickness = 8;

// The external height of the hanger.
hanger_height = 46;

// Rod tilt angle. User to compensate for the clearance in the 
// hanging slot. Tweak to have the rod roughly leveled.
rod_tilt_angle = 3;

nut_cavity_depth = 5;

nut_cavity_diameter = 12.5;

// Raise the end of the rod by this angle. Use to compensate for 
// free play in the hanger slot.
rod_pitch_angle = 1.0;

// Thickness of the hanger's inner (shorter) wall.
hanger_wall1 = 6;

// Thickness of the hanger's top wall.
hanger_wall2 = 6;

// Thickness of the hanger's outer (longer) wall.
hanger_wall3 = 7;


// Spacer lengths. As many many spacers as you need.
spacer_lengths = [ 9, 9, 9, 9, 9 ];

// The spacers drill diameter.
spacer_id = 6.5;

// The spacers outer diameter.
spacer_od = 11;

// The spacers end chamfer
spacer_chamfer = 0.6;

// The thickness of the stopper at the end of the rod.
stopper_thickness = 4;

/* [Hidden] */

// Circles resolution.
$fn=64;  

hanger_thickness = slot_thickness + hanger_wall1 + hanger_wall3;

// Adding to the internal tab a bump with diagonal edges for easier 
// alighment into the printer hole.
bump_size = 5;

// Small values to maintain manifold.
eps1 = 0.01;
eps2 = 2*eps1;

// The slanted bump to improve insertion into the printer wall.
module bump() {
  translate([hanger_thickness-eps1, -hanger_width/2, hanger_height]) 
  rotate([0, 90, 0]) hull() {
    cube([inner_tab_height, hanger_width, eps1]);  
    translate([bump_size, bump_size, bump_size-eps1])
      cube([inner_tab_height - 2*bump_size, hanger_width-2*bump_size, eps1]);  
  }
}

// The core hanger. Without the rod mount body and the insertion 
// bump.
module hanger() {
  translate([0, -hanger_width/2, 0]) 
  difference() {
    cube([hanger_thickness,  hanger_width, hanger_height]);
    
    translate([hanger_wall3, -eps1, -eps1]) 
        cube([slot_thickness, hanger_width+eps2, 
              hanger_height-hanger_wall2+eps1]);
    
    translate([hanger_wall3 + slot_thickness - eps1, -eps1, -eps1]) 
          cube([hanger_wall1+eps2, hanger_width+eps2, 
                hanger_height-inner_tab_height+eps1]);
  }
}

// The end stopper part.
module end_stopper() {
  difference() {
    union() {
      // Nut housing
      cylinder(d=15, h=8.5); 
      
      // Flat base
      hull() {
        translate([15, 0, 0]) cylinder(d=15, h=5); 
        cylinder(d=15, h=5); 
      }
    }
    // Nut cavity
    translate([0, 0, -eps1]) cylinder(d=nut_cavity_diameter, h=nut_cavity_depth+eps1, $fn=6); 
    
    // Through drill
    translate([0, 0, -eps1]) cylinder(d=6.6, h=20);
  }
}

// A single spacer of given total length.
module spacer(spacer_length) {
  difference() {
    union() {
      // Lower chamfer
      translate([0, 0, 0]) 
          cylinder(d1=spacer_od-2*spacer_chamfer, d2=spacer_od, 
                    h=spacer_chamfer+eps1);
      // Center body.
      translate([0, 0, spacer_chamfer]) 
          cylinder(d=spacer_od, h=spacer_length-2*spacer_chamfer+eps1);
      // Top chamfer
      translate([0, 0, spacer_length-spacer_chamfer]) 
         cylinder(d1=spacer_od, d2=spacer_od-2*spacer_chamfer, 
          h=spacer_chamfer);
    }
    // Drill
    translate([0, 0, -eps1]) cylinder(d=spacer_id, h=spacer_length+eps2);
  }
}

// All spacers in a row.
module spacers() {
  for (i = [0:len(spacer_lengths)-1]){
    translate([15*i, 0, 0]) spacer(spacer_lengths[i]);
  } 
}

// All the small parts (spacers and end stopper).
module small_parts() {
  spacers();
  translate([0, 17, 0]) end_stopper();
}

// The main part.
module base() {
  difference() {
    union() {
      rotate([0, -rod_tilt_angle, 0]) translate([0, 0, -15]) union() {
        bump();
        hanger();
      }
      translate([2+eps1, 0, -3]) rotate([0, -90, 0]) 
      scale([1, 0.9, 1])
      union() {
          cylinder(d=20, h=12);
          cylinder(d1=23, d2=20, h=4);
      }
    }

    // Shaft drill hole
    translate([10, 0, 0]) rotate([0, -90, 0]) 
        cylinder(d=6+0.5, h=30);
    
    // Nut cavity hole
    translate([hanger_wall3+4, 0, 0]) rotate([0, -90, 0]) 
        cylinder(d=nut_cavity_diameter, h=nut_cavity_depth+4, $fn=6);
  }
}

//base();

// Base in the printing orientation. Direction was selected to improve
// strength by having the 3D fibers in the correct direction.
intersection() {
  //translate([-10, -5, 10]) #cube([20, 20, 25]);
translate([0, 0, hanger_width/2]) rotate([-90, 0, 90]) base();
}

translate([-40, -30, 0]) small_parts();

