// Customizeable tolerance test for 3D printers.
// Inspired by Maker's Muse video https://youtu.be/TYuLVN3YHw8

// Up to 7 clearances to test.
clearances = [0.5, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35];

mode = "single"; // [single:One connected model,multi:One part per clearance test]

text_depth = 0.8;
text_size = 4.0;

text_font = "Helvetica:black";

// Screwdriver slot length.
slot_length = 6;

// Screwdriver slot width
slot_width = 2;

// Screwdriver slot depth.
slot_depth = 2.8;
  
// Set to a non zero angle for debugging only.
crosscut_angle = 0;

// Roudness.
$fn=200;

//------------------------------

/* [Hidden] */

// Total height;
h = 15;

// Stator outer diameter.
sd1 = 21;

// Outer centers distance from origin. This is for the 'single' mode.
pitch = 20;

// Rotor base diameter
rd1 = 16;

// Rotor center diameter
rd2 = 8;

// Rotor base height
rh1 = 1;

// Small values for maintaining manifold.
eps1 = 0.01;
eps2 = eps1*2;
eps3 = eps1*3;

// Screwdriver slot at the bottom of the rotor.
module rotor_slot() {
  hull() {
    for(angle = [0, 180]) {
      rotate([0, 0, angle]) translate([slot_length-slot_width, 0, -eps1]) 
          cylinder(d=slot_width, h=slot_depth+eps1);
    }
  }
}

// Rotor text
module rotor_label(msg) {
 linear_extrude(height = text_depth+eps1)
   text(msg, halign="center",valign="center", size=text_size+eps1, font=text_font);
}

// Lower half of a rotor, without the screwdriver slot and text.
module half_rotor() {
  slope_height = (rd1 - rd2) / 2;
  // Base cylinder
  cylinder(d=rd1, h=1);
  // Slope cone
  translate([0, 0, rh1-eps1]) cylinder(d1=rd1, d2=rd2, h=slope_height);
  // Center cylinder
  cylinder(d=rd2, h=h/2+eps1);
}

// Full rotor, with screwdriver slot and text lable.
module rotor(clearance) {
  difference() {
    union() {
      // Bottom half
      half_rotor(); 
      // Top half
      translate([0, 0, h]) mirror([0, 0, 1]) half_rotor();
    }
    rotor_slot();
    translate([0, 0, h-text_depth]) rotor_label(str(clearance));
  }
}

// Lower half of a stator. 
module half_stator(clearance) {
  difference() {
    // Add
    cylinder(d=sd1, h=h/2+eps1);
    // Remove
    translate([0, 0, -eps1]) cylinder(d=rd2+2*clearance, h=h/2+eps3);
    translate([0, 0, -eps1]) 
      cylinder(d1 = rd1+2*rh1+2*clearance+eps2, 
         d2=rd2+2*clearance,
         h = eps1 + rh1 + (rd1-rd2)/2);
  }
}

// Full rotor.
module stator(clearance) {
  half_stator(clearance);
  translate([0, 0, h]) mirror([0, 0, 1]) half_stator(clearance);
}

// A combination of a stator and rotor
module unit(clearance) {
  stator(clearance);
  rotor(clearance);
}

module main() {
  _pitch = (mode == "single") ? pitch : pitch+5;
  outers = min(6, len(clearances)-1);
  unit(clearances[0]);
  if (outers > 0) {
    for (i = [1:outers]) {
      angle = 60*(i-1);
      rotate([0, 0, -angle]) translate([_pitch, 0, 0]) 
        rotate([0, 0, angle]) unit(clearances[i]);
    }  
  }
}

difference() {
main();
  if (crosscut_angle != 0) {
    rotate([0, 0, -crosscut_angle]) translate([0, 0, -eps1]) cube([200, 100, h+eps2]);
  }
}
