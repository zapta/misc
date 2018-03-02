
// Roundness. Higher is slower to compute.
$fn=40;  //90;

eps1 = 0+0.01;
eps2 = 2*eps1;

// Slightly larger than metal ball's diameter
ball_cage_radius = 17;

// 
height = 60;

// Wall thickness
wall = 1.2;

// Controls the height. Fixed.
egg_k1 = 0+0.5;

// Controls the fatness. Fixed.
egg_k2 = 0+0.39;

// 0 for printing, 1 for debugging.
cross_cut = 1;

// Parameteric egg contour path. t angle in [0, 180].
// l = egg vertical length;
function p(t, l) = 
  let(a = l * egg_k1)
  let(b = l * egg_k2) 
  let(x = b*cos(t/4)*sin(t))
  let(y = -a*cos(t))
  [x, y];
    
//Ref
// http://www.geocities.jp/nyjp07/index_egg_by_Itou_E.html
module egg(len) { 
   points=[ for (t= [0 :360/$fn :180]) p(t, len)]; 
  translate([0, 0, len/2])
  rotate_extrude(angle = 360, convexity = 2)
  polygon( points=points);
} 

module ball_cage() {
  intersection() {
    egg(height);
      difference() {
        cylinder(d=ball_cage_radius+2*wall, h=wall+ball_cage_radius, $fn=45);
        translate([0, 0, -eps1]) cylinder(d=ball_cage_radius, h=wall+ball_cage_radius+eps1, $fn=45);
      }
  }
}

module main() {
  difference()  {
    egg(height); 
    intersection() {
      translate([0, 0, wall]) egg(height-2*wall);
      translate([-height/2, -height/2, wall]) 
        cube([height, height, height-2*wall-2]);
    }
  } 
  ball_cage();
}

rotate([0, 0, -90]) { 
  render(1)
  difference() {
    main();
    if (cross_cut != 0) {
      cube([2*height, 2*height, 2*height]);
    }
  }
  if (cross_cut != 0) {
      #translate([0, 0, ball_cage_radius/2+wall]) sphere(d=ball_cage_radius);
  }
}

//egg(5);


