// TODO: cleanup consts and publish as a customizeable.
// TODO: cleanup code.

$fn=90;
slot_fn=6;

eps=0+0.01;

angle=60;

wall=1.6;

aparture=1.6;

horiz_wall=wall/sin(angle);
d1=aparture+2*horiz_wall;
d2=27;

lip_width=  22;// 19; //16.5; // 13.5; //7;
lip_inner_thicknes=1.2;
lip_outer_thicknes=1.2;

rib_width = 3;
rib_height = 1.8;  // 1
rib_length = 4;

chamfer = 1.5;

d3=d2+2*lip_width;
cone_height = tan(angle) * (d2-d1)/2;
cone_side_length = (d2-d1)/(2*cos(angle));
base_height=10;

// m1 = top margin 
// m2 = bottom margin
// k1 = scale factor of top width
// k2 = scale radius of bottom width
module cone_slot(m1, m2, k1=1.0, k2=1.0) {
  ap1 = aparture * k1;
  ap2 = aparture * k2;
  translate([d2/2-wall/2, 0, 0]) 
  rotate([0, angle, 0]) 
  hull() {
    translate([-m2-ap2/2, 0, -wall]) rotate([0, 0, 30]) cylinder(d=ap2, h=2*wall, $fn=slot_fn);
    translate([-(cone_side_length-ap1/2-m1), 0, -wall]) rotate([0, 0, 30]) cylinder(d=ap1, h=2*wall, $fn=slot_fn);
  }
}

module base_slot() {
  translate([d2/2+wall/2, 0, 1+aparture/2]) rotate([0, -90, 0]) {
    hull() {
      rotate([0, 0, 30]) cylinder(d=aparture, h=2*wall, $fn=slot_fn);
      translate([6, 0, 0]) rotate([0, 0, 30]) cylinder(d=aparture, h=2*wall, $fn=slot_fn);
    }
  }
}

module cone() {
  difference() {
    // Outer cone
    cylinder(d1=d2, d2=d1, h=cone_height);
    
    // Inner hollow cone
    translate([0, 0, -eps]) cylinder(d1=d2-2*horiz_wall, d2=d1-2*horiz_wall, h=cone_height+2*eps);
    for (i=[22.5:60:360]) {
      rotate([0, 0, i]) cone_slot(1, 17.7, 0.5);
    }
    for (i=[10:30:360]) {
      rotate([0, 0, i]) cone_slot(5.5, 9, 0.5);
    }
    for (i=[0:18:359]) {
      rotate([0, 0, i]) cone_slot(14.5, 0, 0.7);
    }
  }
}

module base() {
  difference() {
    union() {
      cylinder(d=d2, h=base_height);
      cylinder(d1=d2+2*chamfer, d2=d2, h=chamfer);
    }
    translate([0, 0, -eps]) cylinder(d=d2-2*horiz_wall, h=base_height+2*eps);
    for (i=[0:24:359]) {
      rotate([0, 0, i]) base_slot();
    }
  }  
}

module rib() {
 translate([(d3/2)-rib_length, -rib_width/2, 0]) cube([rib_length, rib_width, rib_height]); 
}

module lip() {
  difference() {
    union() {
      hull() {
        cylinder(d=d3, h=lip_outer_thicknes); 
        cylinder(d=d2, h=lip_inner_thicknes);
      }
      for (i=[0:60:359]) {
        rotate([0, 0, i]) translate([0, 0, lip_outer_thicknes-eps]) rib();
      }
    }
    translate([0, 0, -eps]) cylinder(d=d2-2*horiz_wall, h=10);
  }
}



module main() {
  lip();
  translate([0, 0, lip_inner_thicknes-eps]) base();
  translate([0, 0, lip_inner_thicknes+base_height-2*eps]) cone();
}

main();

//rib();


