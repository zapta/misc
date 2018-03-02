// X-Acto knife case.

// Roundness resolution.
$fn = 90;

eps1 = 0 + 00.01;
eps2 = 2*eps1;

// Base inner length, including the blade slot.
inner_length = 153;

// Base inner width
inner_width = 12;

// Base inner height
inner_height = 12;

// Wall thickness
wall = 1.6;

// Space betwene parts to compensate for printer tolernace.
clearance = 0.3;

// The height of the bottom step outside the base.
step_height = 3; 

// External corner radius.
corner = 4;  

// Blade slot length, should be longer than the visible length fo the blade.
slot_length = 28;

// Width of blade slot.
slot_width = 3;

// Centered at x=0, y=0. On z=0 plane.
module rounded_cube(xlen, ylen, zlen, r) {
  translate([r-xlen/2, r-ylen/2, 0]) minkowski() {
    cube([xlen-2*r, ylen-2*r, zlen/2]);
    cylinder(r=r, h=zlen/2);
 }
}

module base() {
  difference() {
    // Add solid body
    union() {
      rounded_cube(
         inner_length + 4*wall + 2*clearance,
         inner_width + 4*wall + 2*clearance,
         step_height,
         corner);
      
       rounded_cube(
          inner_length + 2*wall,
          inner_width + 2*wall,
          inner_height + wall,
          max(eps1, corner - wall - clearance));
    }
    
    // Remove cavity
    translate([slot_length/2, 0, wall]) 
    rounded_cube(
        inner_length - slot_length,
        inner_width,
        inner_height + eps1,
        max(eps1, corner - wall - clearance - wall));
    
    // Remove blade slot
    translate([-inner_length/2, -slot_width/2, wall])
        cube([slot_length+eps1, slot_width, inner_height+eps1]);
  }      
}

module cover() {
  difference() {
    rounded_cube(
       inner_length + 4*wall + 2*clearance,
       inner_width + 4*wall + 2*clearance,
       inner_height + 2*wall - step_height,
       corner);  

    translate([0, 0, wall])
    rounded_cube(
       inner_length + 2*wall + 2*clearance,
       inner_width + 2*wall + 2*clearance,
       inner_height + eps1,
       max(eps1, corner - wall - clearance));     
  }
}

module main() {
  translate([0, 40, 0]) base();
  cover();
}

main();
