
$fn=32;

eps1 = 0.01;
eps2 = 0.02;

// Dimensions from here http://reprap.org/wiki/NEMA_17_Stepper_motor
stepper_w = 42;
stepper_length = 34;
stepper_hole_spacing = 31;
stepper_corner= 4;

// Threaded insert hole diameter multiplier. Allows to tweak the diameter.
threaded_insert_diameter_multiplier = 1.0;

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

module stepper_side() {
  translate([-stepper_w/2+stepper_corner, -stepper_w/2, 0])
  cube([stepper_w-2*stepper_corner, eps1, stepper_length]); 
}

module stepper_screw_hole() {
  translate([stepper_hole_spacing/2, stepper_hole_spacing/2, -eps1])
      m3_threaded_insert(15);
}

module stepper_body() {
  difference() {
    hull() {
      for (i = [0:90:270]) {
        rotate([0, 0, i]) stepper_side();  
      }
    }
    for (i = [0:90:270]) {
      rotate([0, 0, i])
        stepper_screw_hole();
    }
  }
}

module main() {
  stepper_body();
}

main();

