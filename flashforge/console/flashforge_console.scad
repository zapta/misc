$fn=36;

eps1=0.001;
eps2=2*eps1;

base_screw_space_x = 170;
base_screw_space_y = 39.35;
base_thickness = 2;
base_corner_radius = 4;
//base_width

module rounded_cube(x, y, h, r) {
  dx = x/2-r;
  dy = y/2-r;
  hull() {
    translate([-dx, -dy, 0]) cylinder(r=r, h=h);
    translate([dx, -dy, 0]) cylinder(r=r, h=h);
    translate([-dx, dy, 0]) cylinder(r=r, h=h);
    translate([dx, dy, 0]) cylinder(r=r, h=h);
  }
}


module base_holes() {
  dx=base_screw_space_x/2;
  dy=base_screw_space_y/2;
  translate([-dx, -dy, -eps1]) cylinder(d=2.5, h=base_thickness+eps2);
  translate([dx, -dy, -eps1]) cylinder(d=2.5, h=base_thickness+eps2);
  translate([-dx, dy, -eps1]) cylinder(d=2.5, h=base_thickness+eps2);
  translate([dx, dy, -eps1]) cylinder(d=2.5, h=base_thickness+eps2);
    
}

module base_tab(x, y, dir) {
  translate([x, y, 0]) rotate([0, 0, dir])  {
    d2=10;  // outer
    l = 5;
    hull() {
      cylinder(d=d2, h= base_thickness);
      translate([l-1, -d2/2, 0]) cube([1, d2, base_thickness]);
    }
  }
}

module base_tabs() {
  dx=base_screw_space_x/2;
  dy=base_screw_space_y/2;
  base_tab(-dx, -dy, 0);  
  base_tab(dx, -dy, 180);  
  base_tab(-dx, dy, 0);  
  base_tab(dx, dy, 180);  
}

module base_plate() {
  difference() {
    union() {
      base_tabs();
      rounded_cube(171.5, 73.3, 2, 4);
    }
    base_holes();
  }
}

module base_bump() {
  hull() {
    x=162.5;
    y=68;
    r=4;
    rounded_cube(x, y, base_thickness, r);
    translate([-(x/2-r), -(y/2-r), 70]) sphere(r=r);
    translate([(x/2-r), -(y/2-r), 70]) sphere(r=r);
    translate([-(x/2-r), (y/2-r), 8]) sphere(r=r);
    translate([(x/2-r), (y/2-r), 8]) sphere(r=r); 
  }
}

module base_hollow() {
  x=162.5-4;
  y=68-4;
  r=3;
  hull() {
    translate([0, 0, -eps1]) rounded_cube(x, y, 1, 3);
    translate([-(x/2-r), -(y/2-r), 70-2]) sphere(r=r);
    translate([(x/2-r), -(y/2-r), 70-2]) sphere(r=r);
    translate([-(x/2-r), (y/2-r), 8-2]) sphere(r=r);
    translate([(x/2-r), (y/2-r), 8-2]) sphere(r=r); 
  }

  
    
}

module main() {
  difference() {
    union() {
      base_plate();
      base_bump();
    }
    base_hollow();
  }
}

main();















