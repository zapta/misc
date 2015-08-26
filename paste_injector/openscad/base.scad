

$fn=180;


//guide_len = h1+h2-2;
guide_hole_diameter = 2.5;
guide_spacing = 10.5;
guide_hole_offset = 1.5;

shaft_hole_diameter = 5.5;

//base_diameter = 20;
base_height = 10;

base_width = 45;

cavity_wall = 1.5;
cavity_height = 26;
cavity_diameter = 22;

motor_screws_space = 35;
motor_screws_holes_offset = 8;
motor_screws_holes_diameter = 2.5;
motor_screws_holes_depth = 25;

bottom_screws_space = 35;
bottom_screws_holes_diameter = 2.5;
bottom_screws_holes_depth = 25;

total_height = base_height + cavity_height;

echo("*** Total Height: ", total_height);

base_corner_radius = 3;
base_corner_offset = 0;

eps1 = 0.001;
eps2 = 2*eps1;

module guide_holes() {
//difference() {
// cylinder(d=base_diameter, h=base_height);

translate([-guide_spacing/2, 0, -eps1]) cylinder(d=guide_hole_diameter, h=base_height+eps1-guide_hole_offset);
  
 translate([-guide_spacing/2, 0, -eps1]) cylinder(d=guide_hole_diameter/3, h=base_height+eps2);
  
  translate([guide_spacing/2, 0, -eps1]) cylinder(d=guide_hole_diameter, h=base_height+eps1-guide_hole_offset);
  
   translate([guide_spacing/2, 0, -eps1]) cylinder(d=guide_hole_diameter/3, h=base_height+eps2);

//}
}

module motor_holes() {
  translate([motor_screws_space/2, -motor_screws_holes_offset, total_height-motor_screws_holes_depth]) 
      cylinder(d=motor_screws_holes_diameter, h=motor_screws_holes_depth+eps1); 
    translate([-motor_screws_space/2, -motor_screws_holes_offset, total_height-motor_screws_holes_depth]) 
      cylinder(d=motor_screws_holes_diameter, h=motor_screws_holes_depth+eps1); 

}

module bottom_holes(d) {
   
  translate([bottom_screws_space/2, 0, -eps1]) 
      cylinder(d=d, h=bottom_screws_holes_depth+eps1); 
  
  translate([-bottom_screws_space/2, 0, -eps1]) 
      cylinder(d=d, h=bottom_screws_holes_depth+eps1); 
}

module shaft_hole() {
 translate([0, 0, -eps1]) cylinder(d=shaft_hole_diameter, h=base_height+eps2);
}


//test_base();

module blank(h) {
  hull() {
    cylinder(d=cavity_diameter+2*cavity_wall, h=h);
    
    translate([base_width/2-1, -(cavity_diameter+2*cavity_wall)/2, 0]) cube([1, 1, h]);
    translate([-base_width/2, -(cavity_diameter+2*cavity_wall)/2, 0]) cube([1, 1, h]); 
    
    translate([base_width/2-base_corner_radius, base_corner_offset, 0]) 
        cylinder(r=base_corner_radius, h=h);
    
    translate([-(base_width/2-base_corner_radius), base_corner_offset, 0]) 
        cylinder(r=base_corner_radius, h=h);
  }
}


module cavity() {
  translate([0, 0, base_height]) cylinder(d=cavity_diameter, h=total_height);  
}

module body() {
  difference() {
    blank(total_height);
    cavity();
    guide_holes();
    shaft_hole();
    motor_holes();
    bottom_holes(bottom_screws_holes_diameter);
  }
}

module plate() {
  difference() {
    blank(3);
    translate([0, 0, -eps1]) cylinder(d=18.5, h=10);
    bottom_holes(4);
  }  
}

module main() {
  body();
  
  translate([0, -40, 0]) plate();
}

main();



//bottom_holes();

//motor_holes();



