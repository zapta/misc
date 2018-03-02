// Windoe blind cord/chain pulls.



// A small positive value to maintain manifold
eps=0 + 0.01;

//---------- consts

// Set to 1 for debugging, 0 for printing.
cross_cut = 1;

// Resolution
$fn=90;

// Total part height.
height = 30;

top_end_radius = 1;
top_diameter = 7;

bottom_end_radius = 2;
bottom_diameter = 18;

// Radius of side curvature.
curve_radius =100;

// Center hole for the cord or chain.
hole_diameter = 3.5;
hole_chamfer = 0.5;

// Cavity at the bottom of the part.
cavity_top_diameter = 8;
cavity_bottom_diameter = 10;
cavity_depth = 17;

// Slope of internal overhang.
cavity_chamfer_slope = 0.8;




// TODO: flatten some of this consts
r1=bottom_end_radius;
r2=top_end_radius;
d1=bottom_diameter;
d2=top_diameter;

hole_d = hole_diameter;

cavity_d1 = cavity_bottom_diameter;
cavity_d2 = cavity_top_diameter;
cavity_h = cavity_depth;
chamfer = hole_chamfer;

r3 = curve_radius;
 
 // --------------- 2D
 
// Center of bottom circle
gx1 = d1/2-r1;
gy1 = r1;

gx2 = d2/2-r2;
gy2 = height - r2;

gdx = gx2 - gx1;
gdy = gy2 - gy1;

echo("dgx", gdx);
echo("dgy", gdy);

l1 = r1 + r3;
l2 = r2 + r3;

// alpha = angle of thrid circle center relative to bottom circle center.
function distance(alpha) = 
  let(
    x1=l1*cos(alpha), 
    y1=l1*sin(alpha),
    dx=x1-gdx,
    dy=y1-gdy,
    l=sqrt(dx*dx + dy*dy)
  )
  abs(l2 - l);

function iterate(alpha, step) =
  let (
    d0 = distance(alpha),
    d1 = distance(alpha+step)
  )
  (d0 < 0.01) ? [alpha, step, d0, d1] //alpha
    :  
    ((d1 < d0)  ? iterate(alpha+step, step)
      : iterate(alpha, -step/2));
      
function center_circle() =
  let (
    // Starting the search at alpha = 45 deg, step = 5 deg.
    solution = iterate(45, 5),
    alpha = solution[0]
  )
  [[d1/2-r1+l1*cos(alpha), r1+l1*sin(alpha)], solution];

module profile() {
  intersection() {
    difference() {
      hull() {
        translate([d1/2-r1, r1]) circle(r=r1);  
        translate([d2/2-r2, height-r2]) circle(r=r2);
        square([eps, height]);
      }
      translate(solution[0]) circle(r=r3, $fn=3*$fn);
    }
    square(max(height, d1, d2));
  }
}

solution = center_circle();
echo("Solution", solution);

// ----------------- 3D

module hole() {
  translate([0, 0, -eps]) cylinder(d=hole_d, h=height+2*eps);
  translate([0, 0, height-chamfer]) 
    cylinder(d1=hole_d, d2=hole_d+2*chamfer, h=chamfer+eps);
}

module cavity() {
  slope_h = cavity_chamfer_slope*((cavity_d2 - hole_d)/2);
  translate([0, 0, -eps]) cylinder(d1=cavity_d1, d2=cavity_d2, h=cavity_h-slope_h+2*eps);
  translate([0, 0, cavity_h-slope_h]) cylinder(d1=cavity_d2, d2=hole_d, h=slope_h);
}

module main() {
  difference() {
    rotate_extrude() profile();  
    hole();
    cavity();
  }
}

rotate([0, 0, -90]) 
difference() {
  main();
  if (cross_cut != 0) {
    translate([0, 0, -eps]) cube(height+2*eps);
  }
}
