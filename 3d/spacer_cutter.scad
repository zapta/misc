$fn = 32;

spacer_d = 8;
spacer_l = 3.3;

knife_w = 1;

w = 14;
l = 13;
h = 12;

base=2;

difference() {
  // Block
  translate([-w/2, -l/2, 0]) cube([w, l, h]);

  // spacer cavity
  hull() {
    for (i = [0: 1]) {
    translate([0, spacer_l/2, spacer_d/2+i*20+base]) rotate([90, 0, 0]) 
      cylinder(d=spacer_d, h=spacer_l);
    }
  }
  
  // Knife slot
  translate([-10, -knife_w/2, base+spacer_d/3]) cube([20, knife_w, 20]);
}