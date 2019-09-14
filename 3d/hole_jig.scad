$fn=32;

bar_w = 16+0.1;
bar_h = 13+0.3;

wall=3;

//l1 = 10;
//l2 = 15;

l1 = 15;
l2 = 15;

l = l1+l2;

eps=0.1;

hole_space=9;
hole_height=3;
//h//ole_depth=10;

release_d = 3;

d=2.5;

module main() {
  difference() {
    translate([0, -bar_w/2-wall, -wall]) 
      cube([l, bar_w+2*wall, bar_h+2*wall]);
    
    translate([l2, -bar_w/2, ]) cube([l1+eps, bar_w, bar_h]);


    for (i = [-1:2:1]) {
     translate([-eps, i*hole_space/2, hole_height]) rotate([0, 90, 0]) cylinder(d=d, h=l2 + 2*eps);
    
    
    translate([l2, i*bar_w/2, 0]) rotate([0, 90, 0]) cylinder(d=release_d, h=l1+eps);
      
        translate([l2, i*bar_w/2, bar_h]) rotate([0, 90, 0]) cylinder(d=release_d, h=l1+eps);
    }
  }
}

rotate([0, -90, 0]) 
main();