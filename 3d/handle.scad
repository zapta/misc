// Parametric handle. Can be mounted with screws or with 
// double sided tape such as 3M 414DC-SF.

// General roundness.
$fn=90;

// Handle bent roudness
bent_fn = 30;

// Center to center distance between the two handle risers.
handle_length = 100;

// Handle height to center of horizontal bar.
handle_height = 30;

// Diameter of the handle.
handle_thickness = 10;

// Increase above 1.0 for a wider handle.
handle_proportion = 2;

// Increase above 0 for a wider flat handle.
_handle_extra_width = max(0, handle_thickness*(handle_proportion-1));

// Radius of the handle curve.
handle_bent_radius = 10;

// Diameter of the base plates.
base_diameter = 18;

// Thickness of base plates.
base_height = 3;

// Increase above 1.0 to have elongated base plates.
base_proportion = 1.5;

base_k = max(0, base_proportion-1);

// Move base in/out
base_offset = 0;

// Rotate the base plates around their center. Useful for non
// circular bases.
base_rotation = 90;

// Radius of filet between base plate and handle.
filet = 3;

// Screw hole diameter
hole_diameter = 3;

// Screw hole depth
hole_depth = 15;


eps1 = 0+0.01;
eps2 = 2*eps1;

module linear_filet(l, r) {
  difference() {
    translate([0, -l/2, 0]) cube([r, l, r]);  
    translate([r, l/2+eps1, r]) rotate([90, 0, 0]) cylinder(r=r, h=l+eps2);
  }
}

module half_round_filet(d, h) {
  difference() {
    cylinder(d=d+2*h, h=h);

    translate([0, 0, h]) rotate_extrude()
      translate([d/2+h, 0, 0])
        circle(r = h);
    
    translate([0, 0, -eps1]) cylinder(d=d-eps2, h=h+eps2);
    
    translate([-d/2-h-eps1, eps1, -eps1]) cube([(d+2*h)+eps2, d/2+h+eps2, h+eps2]);
  }
}

//module filet(d, h) {
//  difference() {
//    cylinder(d=d+2*h, h=h);
//
//    translate([0, 0, h]) rotate_extrude()
//      translate([d/2+h, 0, 0])
//        circle(r = h);
//    
//    translate([0, 0, -eps1]) cylinder(d=d-eps2, h=h+eps2);
//  }
//}

module slice(x, z, a) {
  translate([x, 0, z]) rotate([0, -a, 0]) 
  hull() {
    translate([0, -_handle_extra_width/2, 0]) cylinder(d=handle_thickness, h=eps1);
    translate([0, _handle_extra_width/2, 0]) cylinder(d=handle_thickness, h=eps1);
  }
}

module arc(r) {
  // Using $n sections for 90deg bend result in X4 number of 
  // sections. That's ok since this radius is typically larger
  // than the others.
  n = bent_fn;  //ceil($fn/4); 
  for (i = [1:n]) {
    hull() {
      a0 = (i-1)*90/n;
      a1 = (i)*90/n;
      slice(r*cos(a0)-r, r*sin(a0), a0);
      slice(r*cos(a1)-r, r*sin(a1), a1);
      
//      translate([0, 10, 0]) {
//        slice(r*cos(a0)-r, r*sin(a0), a0);
//        slice(r*cos(a1)-r, r*sin(a1), a1);
//      }

    }
  }
}

module half_handle_no_hole() {
  // Vertical bar
  //translate([handle_length/2, 0, 0]) cylinder(d=handle_thickness, h=handle_height-handle_bent_radius);
  
  hull() {
    slice(handle_length/2, 0, 0);  
    slice(handle_length/2, handle_height-handle_bent_radius, 0);  
  }
 
  // Arc
  translate([handle_length/2, 0, handle_height - handle_bent_radius]) arc(handle_bent_radius);
  
  
 
  
  // Horizontal bar
//  translate([handle_length/2 - handle_bent_radius, 0, handle_height]) rotate([0, -90, 0]) cylinder(d=handle_thickness, h=handle_length/2 - handle_bent_radius);
    
   hull() {
    slice(0, handle_height, 90);  
    slice(handle_length/2 - handle_bent_radius, handle_height, 90);  
  }
  
  if (base_height > 0 && base_diameter > 0) {
    // Base
    translate([handle_length/2, 0, 0]) 
    rotate([0, 0, base_rotation])
    translate([base_offset, 0, 0]) 
    hull() {
      translate([-base_k*base_diameter/2, 0, 0]) cylinder(d=base_diameter, h=base_height);
      
      translate([base_k*base_diameter/2, 0, 0]) cylinder(d=base_diameter, h=base_height);
    }
    
    // Filet
    if (filet > 0) {
      for (side = [0,1]) {
        // Round
        mirror([0, side, 0]) 
          translate([handle_length/2, -_handle_extra_width/2, base_height-eps1]) 
        half_round_filet(  handle_thickness, filet);
       // Linear 
       translate([handle_length/2, 0, 0]) mirror([side, 0, 0]) translate([handle_thickness/2, 0, base_height-eps1]) linear_filet(_handle_extra_width+eps2, filet);
        
      }
    }
  }  
}

module half_handle() {
  difference() {
    half_handle_no_hole();
    translate([handle_length/2, 0, -eps1]) cylinder(d=hole_diameter, h=hole_depth+eps1);
  }
}

module handle() {
  half_handle();
  mirror([1, 0, 0]) half_handle();
}

module main() {
  //hull() {
    handle();
  //  translate([0, 5, 0]) handle();
  //}
}

main();



//linear_filet(20, 4);

//half_round_filet(20, 5);


