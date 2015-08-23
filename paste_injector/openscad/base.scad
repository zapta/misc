

$fn=180;


//guide_len = h1+h2-2;
guide_hole_diameter = 2.5;
guide_spacing = 10.5;
guide_hole_offest = 1.5;

screw_hole_diameter = 5;

base_diameter = 20;
base_height = 10;

eps1 = 0.001;
eps2 = 2*eps1;

difference() {
cylinder(d=base_diameter, h=base_height);
 cylinder(d=screw_hole_diameter, h=base_height+eps2);

translate([-guide_spacing/2, 0, guide_hole_offest]) cylinder(d=guide_hole_diameter, h=base_height+eps2);
  
  translate([guide_spacing/2, 0, guide_hole_offest]) cylinder(d=guide_hole_diameter, h=base_height+eps2);

}