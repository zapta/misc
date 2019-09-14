
eps = 0 + 0.05;

// The text message
text_message = "Charlie";

// Text size
text_size = 7;

// Text depth
text_depth = 0.5;

// A proportion to control the text position along arm 1
text_position = 0.6;

// Inter character spacing. Normal is 1.0.
text_spacing = 1.1;

// Text font 
text_font = "Helvetica:black";

// Amount of inset of first(layers) to avoid 'elephant foot'.
first_layers_inset_width = 0.3;

// Height of first layer(s) to inset. Typically set to layer height to inset a single layer.
first_layers_inset_height = 0.2;


// Length, measured from pivot center
arm_length = 88;

// Overall width
arm_width = 14;

// Thickness of a single arm
arm_thickness = 6; 

// Space between the two arms
arm_space = 1;

// Pivot diameter.
pivot_id = arm_thickness;

// Outer diameter of pivote case.
pivot_od = 2*arm_thickness;

// Thickness of pivote case.
pivot_wall = 3;

// Pivot margin in horizontal direction (intra layer)
pivot_hspace = 0.3;

// Pivot margin in vertical direction (inter layer)
pivot_vspace = 0.4;

// Offset of the slot at the latch end of arm 2.
arm2_end_slop = 0.5;

// Corner radius at the latch and of arm 2.
arm2_end_radius = 2;

// Thickness of the latch L shape part.
latch_thickness = 2;

// Thickness of the latch L shape part.
latch_slot_thickness = 0.8;

// Length of the latch clearance slot.
latch_slot_length = 10;

// The latching distance.
latch_hook_depth = 1.7;  

// Controls the height latch height, for easier opening.
latch_height_factor = 1.5;

// The ridge (slot) height.
ridge_height = 1.5;

anti_ridge_depth = ridge_height + 0;

// Circle smoothness
$fn = 128;

module arm1() {
  difference() {
    union() {
      // Add arm. 
      translate([0, -arm_thickness, 0]) 
      cube([arm_length, arm_thickness, arm_width]);
      
      // Add pivot holder
      cylinder(d=pivot_od, h=arm_width);
      
      // Add latch
      translate([arm_length, 0, 0]) 
        latch();
    }
    
    // Substruct latch slot
    translate([arm_length, -arm_thickness+latch_thickness, 0])
      latch_slot();
          
    // Substract pivote hole
    translate([0, 0, -eps]) 
      cylinder(d=pivot_id, h=arm_width + 2*eps);
    
    // Substract Pivot clearance slope
    {
      r1 = pivot_id/2;
      r2= pivot_od/2;
      r = (r2*r2 - r1*r1)/(2*r1) + r1;      
      translate([0, r-r1, pivot_wall])
        cylinder(d=2*r, h=arm_width-2*pivot_wall);
    }
    
    // Substract anti ridge
    translate([0, 0, arm_width/2])
      rotate([90, 0, 0])
        ridge(anti_ridge_depth, arm_length-eps);
    
    // Substract text
    translate([arm_length*text_position, -arm_thickness+text_depth, arm_width/2]) 
rotate([90, 180, 0]) linear_extrude(height = text_depth+eps)
     text(text_message, halign="center",valign="center", size=text_size, spacing=text_spacing, font=text_font);
  }
}


// Latch. Added to arm1
module latch() {
  // The latch 'hook'
  translate([0, arm_thickness + arm_space, 0])
  hull() {
    cube([latch_thickness, latch_thickness*latch_height_factor + latch_hook_depth, arm_width]);
    translate([-latch_hook_depth, 0, 0]) 
      cube([latch_hook_depth, latch_thickness, arm_width]);
  }

  translate([0, -arm_thickness, 0]) 
    cube([latch_thickness, 
       2*arm_thickness+arm_space+eps,   
      arm_width]);

  l = latch_slot_length + latch_thickness + eps;
  translate([-l + latch_thickness, -arm_thickness, 0]) 
    cube([l, latch_thickness, arm_width]);
}

// Latch slot. Substracted from arm1
module latch_slot() {
  translate([-latch_slot_thickness, 0, -eps])
    cube([latch_slot_thickness, arm_thickness, arm_width+2*eps]);

  translate([-latch_slot_length, 0, -eps])
    cube([latch_slot_length, 
      latch_slot_thickness,    
      arm_width+2*eps]);
}

module arm2() {
  // Arm
  translate([pivot_od/2+pivot_hspace, arm_space, 0]) 
    hull() {
      l = arm_length - pivot_od/2 - pivot_hspace;
      
      translate([l-1, arm_thickness-1, 0])
      cube([1, 1, arm_width]);

      translate([l-arm2_end_radius-arm2_end_slop, arm2_end_radius, 0])
        cylinder(r=arm2_end_radius, h=arm_width);

      cube([eps, arm_thickness, arm_width]);
    }
    
          
    // Add ridge
    translate([pivot_od/2+pivot_hspace + arm2_end_radius, 
      arm_space+eps, arm_width/2])
        rotate([90, 0, 0])
           ridge(ridge_height, arm_length-pivot_od/2-pivot_hspace-2*arm2_end_radius-arm2_end_slop);
  
   // Add pivote cylnder
   cylinder(d=pivot_id-2*pivot_hspace, h=arm_width); 
 
   difference() {
     // Add ,,,
     hull() {
       cylinder(d=pivot_id-2*pivot_hspace, h=arm_width);  
        
       translate([pivot_od/2+pivot_hspace, arm_space, 0])
       cube([eps, arm_thickness, arm_width]) ;
     }  
   
   // Substract ...
   translate([0, 0, -eps]) 
     cylinder(
        d=pivot_od+2*pivot_hspace, 
        h=pivot_wall+pivot_vspace+eps);
   
   // Substract ...
   translate([0, 0, arm_width-pivot_wall-pivot_vspace]) 
     cylinder(
       d=pivot_od+2*pivot_hspace, 
       h=pivot_wall+pivot_vspace+eps);
  }
}

module ridge(h, l) {
  hull() {
    translate([0, -h, 0])
      cube([l, 2*h, eps]);
  
    translate([0, -eps, -eps])
      cube([l, 2*eps, h]);
  }
}

module main() {
  arm1();
  rotate([0, 0, 45]) arm2();
}


// A library module to inset the first layer to avoid 
// 'elephant foot'.
module inset_bottom(w=0.4, h=0.2, bounding_size = 200, eps=0.01) {
  if (w <= 0 || h < 0) {
    children();
  } else {
    // The top part of the children without the inset layer.
    difference() {
      children();
      // TODO: use actual extended children projection instead
      // of a clube with arbitrary large x,y values.
      translate([0, 0, -9*h]) 
          cube([bounding_size, bounding_size, 20*h], center=true);
    }
    // The inset layer.
    linear_extrude(height=h+eps) offset(r = -w) projection(cut=true)
      children();
  }
}

// Adjust main to printing position and inset first
// layer.
inset_bottom(w=first_layers_inset_width, h=first_layers_inset_height)
  translate([arm_length/2, 0, arm_width-eps])
  rotate([0, 180, 0])
  main();
