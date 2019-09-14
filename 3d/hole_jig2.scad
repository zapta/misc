$fn=32;

bar_w = 15+0.2;
bar_h = 13+0.2;

wall1 = 4;
wall2 = 16;

//l1 = 10;
//l2 = 15;

//l1 = 5;
//l2 = 5;

l = 15;

eps=0.1;

hole_space=7;
hole_offset = 6.2;
//hole_height=3;
//h//ole_depth=10;

release_d = 2;

hole_d=2.5;

module main() {
  difference() {
    translate([0, -bar_w/2-wall2, -wall1]) 
      cube([l, bar_w+2*wall2, bar_h+2*wall1]);
    
    translate([-eps, -bar_w/2, ]) cube([l+2*eps, bar_w, bar_h]);


for (i = [-1:2:1]) {
   translate([hole_offset, bar_w/2+wall2+eps, bar_h/2+i*hole_space/2]) rotate([90, 0, 0]) cylinder(d=hole_d, h=bar_w+2*wall2+2*eps);
}
//    for (i = [-1:2:1]) {
//     translate([-eps, i*hole_space/2, hole_height]) rotate([0, 90, 0]) cylinder(d=d, h=l2 + 2*eps);
//    
//    
//    translate([l2, i*bar_w/2, 0]) rotate([0, 90, 0]) cylinder(d=release_d, h=l1+eps);
//      
//        translate([l2, i*bar_w/2, bar_h]) rotate([0, 90, 0]) cylinder(d=release_d, h=l1+eps);
//    }
  }
}

rotate([0, -90, 0]) 
main();