// A piggy bank for used X-Acto blades #2 and smaller.

eps1 =  0+0.01;
eps2 = 2*eps1;

// Roundness
$fn=60;

// External diameter
d = 40;

// External height.
h = 62;

// Rounding on cylinder faces.
filet = 3;

// Thickness of all walls.
wall = 2;

// Length of the slot opening.
slot_length = 15;

// Width of the slot opening.
slot_width = 3;

// Length of the internal slot guard.
guard_height = 5;

// Set to 1 for debugging, 0 for printing.
debugging = 0;

module elongated_cylinder(d, h, l) {
  hull() {
    dy = max(0, (l-d)/2);
    translate([0, dy, 0]) cylinder(d=d, h=h);
    translate([0, -dy, 0]) cylinder(d=d, h=h);
  }  
}

module rounded_cylinder(d, h, r) {
  translate([0, 0, r])
  minkowski()
  {
  cylinder(d=d-2*r, h=h-2*r);
    sphere(r=r);
  }
}

module main() {
  difference() {
    union() {
    difference() {
      // Add external cylinder
      rounded_cylinder(d, h, filet);      
      // Remove internal cavity
      translate([0, 0, wall]) 
        rounded_cylinder(d-2*wall, h-2*wall, filet);
    }   
    // Add internal slot guard
    translate([0, 0, wall-eps1])
        elongated_cylinder(slot_width+2*wall, guard_height, slot_length+2*wall);
  } 
    translate([0, 0, -eps1])
      elongated_cylinder(
          slot_width, 
          wall+eps2+guard_height, 
          slot_length);  
  }
}

//translate([0, 0, h])
//rotate([0, 180, 0])
render(1)
rotate([0, 0, 180])
difference() {
  main();
  if (debugging != 0) {
    translate([-100, 0, -100]) cube([200, 200, 200]);
  }
}

