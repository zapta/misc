
// Mode. Use "print" for actual printing.
mode = "printing";  // [demo, printing]

// Number of trays to generate.
num_trays = 5;

// Reduce the inner trays height to be flush with the outer tray.
nested_height = "y";  // [y, n]

// 105.4, 85.4, 18.2

// Total length of the outer tray.
outer_length = 105.4;

// Total width of the outer tray.
outer_width = 85.4;

// Total height of the outer tray. 
outer_height = 18.2;

// Radius of the side corners. Same for all trays.
side_radius = 5;

// A small radius at the bottom corners of the trays.
bottom_radius = 1.0;

// The thickness of the side wall of each tray.
side_wall = 2;

// The thickness of the bottom of each tray.
bottom_wall = 1.6;

// Allow this space around trays when inserterd inout outer trays.
side_margin = 0.6;

// Assume this vertical space between nested trays. Used to tweak 
// the nesteted height.
bottom_margin = 0.0;

// Vertical spacing in demo mode. Doesn't affect printed models.
demo_bottom_margin = 0.1;

// Space between trays on the printing bed.
printing_space = 5;

/* [Hidden] */

// Tiny distance. Used to maintain manifold.
eps1 = 0.001;

// Smoothness of rounded corners. Higher is smoother.
$fn = 90;

// Rounded on the sides.
module rounded_slab1(l, w, h, r1) {
  dx = l/2-r1;
  dy = w/2-r1;
  hull() {
    translate([dx, dy, 0]) cylinder(r=r1, h=h); 
    translate([dx, -dy, 0]) cylinder(r=r1, h=h);
    translate([-dx, dy, 0]) cylinder(r=r1, h=h);
    translate([-dx, -dy, 0]) cylinder(r=r1, h=h); 
  }
}

module rounded_slab2(l, w, h, r1, r2) {
   translate([0, 0, r2]) minkowski() {
    rounded_slab1(l-2*r2, w-2*r2, eps1, r1-r2);
    sphere(r=r2, $fn=32);
  }
  translate([0, 0, r2])rounded_slab1(l, w, h-r2, r1);
}

module tray(l, w, h, r1, r2) {
  echo("tray():", l, w, h, r1, r2);
  difference() {
    rounded_slab2(l, w, h, r1, r2);
    translate([0, 0, bottom_wall]) 
      rounded_slab2(l-2*side_wall, w-2*side_wall, h, r1-side_wall, r2);
  }
}

// 0 = outer, 1 = one before outer, ...
module tray_by_index(i) {
  l= outer_length - i*2*(side_wall + side_margin);  
  w= outer_width - i*2*(side_wall + side_margin); 
  h = (nested_height == "y") 
      ? (outer_height - i * (bottom_wall + bottom_margin)) 
      : outer_height;
  tray(l, w, h, side_radius, bottom_radius); 
}

module demo_mode() {
  difference() {
    union() {
      for (i =[0:num_trays-1]) {
        translate([0, 0, i*(demo_bottom_margin + bottom_wall)]) tray_by_index(i);
      }
    }
    translate([0, 0, -eps1]) cube([outer_length, outer_width, 2*num_trays*outer_height]);
  }
} 

module printing_mode() {
  for (i =[0:num_trays-1]) {
    translate([0, i*(printing_space + outer_width - i*(side_wall+side_margin)), 0]) tray_by_index(i);
  }
}  

module main() {
  if (mode == "demo") {
    demo_mode();
  } else {
    printing_mode();
  }
}

main();

//rounded_slab2(100, 80, 15, 5, 2);

////translate([0, 0, 2]) rounded_slab2(100-4, 60-4, 15, 5-2, 2);

//translate([0, 0, 2-eps1])rounded_slab1(100, 60, 15-2+eps1, 5);

//translate([0, 0, 0]) rounded_slab2(100, 60, 15, 5, 2);

//#translate([0, 0, 2*eps1]) rounded_slab1(100, 60, 15, 5);






  
  