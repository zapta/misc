// 3D printer Bowden clip customizer.

// How many clips to print.
count = 3;

// Clip's thickness
//ring_thickness = 1.8;  // white
ring_thickness = 1.4;  // green

// Inner diameter of the clip
ring_id = 7;
// Outer diameter of the clip
ring_od = 11;
// Width of the clip's opening
ring_cut_width = 5.5;
// Width of the vertical tab.
tab_width = 5.8;
// Height of the vertical tab.
tab_height = 1.5;
// Thickness of the vertical tab.
tab_thickness = 1.6;
// Controls the distance between the vertical tab and the ring.. 
tab_offset = 0;


/* [Hidden] */

$fn = 64;
eps = 0.01;

module bowden_clip_tab() {
  ring_width = (ring_od - ring_id)/2;
  base_length = ring_width + tab_offset + tab_thickness;
  translate([-base_length-ring_id/2, -tab_width/2, 0]) 
    cube([base_length, tab_width, ring_thickness]);
  translate([-ring_od/2-tab_offset-tab_thickness, -tab_width/2, 0])
    cube([tab_thickness, tab_width, ring_thickness+tab_height]);
  
}

module bowden_clip_ring() {
  difference() {
    cylinder(d=ring_od, h=ring_thickness);
    translate([0, 0, -eps]) 
      cylinder(d=ring_id, h=ring_thickness+2*eps);
    translate([0, -ring_cut_width/2, -eps]) 
      cube([ring_od/2+eps, ring_cut_width, ring_thickness+2*eps]);
  }
}

module bowden_clip() {
  bowden_clip_ring();
  bowden_clip_tab();
}

for (i = [0 : count-1]) {
  translate([i*(ring_od + 3), 0, 0]) rotate([0, 0, -90]) bowden_clip(); 
}
