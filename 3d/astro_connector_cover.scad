// A cover for Astroflight zero loss 2 contact female connector.

wall_thickness=1.6;
base_thickness=1.6;

// Tweak to have a tight fit. 
cavity_extra_width = 0.4;

// Tweak if needed to adjust the length of the cavity.
cavity_extra_length = 1.0;

// Extra cavity depth. Default value should be good.
cavity_extra_depth = 0.0;

// Internal readius of the cavity vertical corners. 
cavity_corner_radius = 0.2;

cavity_width  = 7 + cavity_extra_width;
cavity_length = 13 + cavity_extra_length;
cavity_depth = 10 + cavity_extra_depth;

external_width  = cavity_width  + 2*wall_thickness; 
external_length = cavity_length + 2*wall_thickness; 
external_height = base_thickness + cavity_depth;
external_corner_radius = cavity_corner_radius + wall_thickness;

// Adding '0' to make it hidden in thingiverse.
$fn = 0 + 64;
eps1 = 0 + 0.01;

// A block rounded on one and and two rounded corners at the other end,
// center on the z=0 plane.
module shape(w, l, h, r) {
  hull() {
    // Large radius.
    translate([-(l/2-w/2), 0, 0]) cylinder(d=w, h=h);   
    // Two corners.
    translate([(l/2-r), -(w/2-r), 0]) cylinder(r=r, h=h); 
    translate([(l/2-r), (w/2-r), 0]) cylinder(r=r, h=h); 
  }
}

// The entire object.
module main() {
  difference() {  
    // Body 
    shape(external_width, external_length, external_height,
        external_corner_radius);
    // Cavity.
    translate([0, 0, base_thickness]) 
        shape(cavity_width, cavity_length, cavity_depth+eps1, cavity_corner_radius);
  }
}

main();
