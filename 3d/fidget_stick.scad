// Customizeable fidget stick

eps1 = 0 + 0.01;
eps2 = 2 * eps1;

// Resolution (lower = faster rendering, higher = better print quality)
$fn = 120;

slices = max(12, ceil($fn/4));

// 0 = normal, 1 = cross cut (for debugging)
cross_cut = 0;

// Total height in mm.
height = 90;

// Diameter at ends in mm.
base_diameter = 19;

d1 = base_diameter;

// Additional diameter at the center as a fraction of total height.
fatness = 0.5;

d2 = d1 * (1 + fatness);

// Delta r between center and ends.
dr = (d2-d1)/2;

// Compute R for side radius
R = (dr*dr + height*height/4) / (2 * dr);

// Side wall thickness in mm.
side_wall = 0.9;

// The height of top and bottom solid weight as a fraction of total height. [0, 0.5]
weight_height_fraction = 0.15;

end_wall = max(side_wall, min(height/2+eps1, weight_height_fraction * height));

// Slot heights as fractions of total height.
ring_height_fractions =  [0.05, 0.1, 0.15, 0.2];

// Ring cut depth in mm.
ring_depth = 0.6;

// Inset bottom by this amount to compensate for first layer squashing.
bottom_inset_width = 0.5;

// Hight of botton layer(s) to inset.
bottom_inset_height = 0.2;

// From thingiverse #2219095
module inset_bottom(w=bottom_inset_width, h=bottom_inset_height, bounding_size = 2*height, eps=eps1) {
  if (w == 0 || h < 0) {
    children();
  } else {
    // The top part of the children without the inset layer.
    difference() {
      children();
      // TODO: use actual extended children projection instead
      // of a clube with arbitrary large x,y values.
      translate([0, 0, -9*h])
          cube([bounding_size, bounding_size, 20*h], center=true);
    }
    // The inset layer.
    linear_extrude(height=h+eps) offset(r = -w) projection(cut=true)
      children();
  }
}

// Comptue external radius as a function of z.
// h is in [0, height]
function radius_at_height(h) =
  let (dz = (h - height/2))
  (d2/2 - (R - sqrt(R*R - dz*dz)));  

// A ring cut of given radius. 
module ring(r) {
  w = 2*ring_depth; 
  rotate_extrude(angle = 360, convexity = 2)  
  polygon( points=[[r, 0], [r+w, w], [r+w, -w]]);
}

// All ring cuts.
module rings_support() {
  for(q = ring_height_fractions) {
    h = height * q;
    r = radius_at_height(h) - sqrt(2)*ring_depth;
    translate([0, 0, h]) ring(r-side_wall);
    translate([0, 0, height-h]) ring(r-side_wall);
  }
}

// All ring cuts.
module rings_cuts() {
  for(q = ring_height_fractions) {
    h = height * q;
    r = radius_at_height(h) - ring_depth;
    translate([0, 0, h]) ring(r);
    translate([0, 0, height-h]) ring(r);
  }
}

// Returns a vector of points [x, y],
// where y is increasing in the range [0, height] and x 
// is the radius at that point.
function contour_points(extra_r, i=0) =
  let(h = i * height / slices)
  let(r = radius_at_height(h) + extra_r)
  (i == slices)
    ?  [[r, h]]
    :  concat([[r, h]], contour_points(extra_r, i+1));

module solid_body(extra_r) {
  rotate_extrude(angle = 360, convexity = 2) 
  polygon( points=concat([[0, height], [0, 0]], contour_points(extra_r))); 
}

module main() {
  difference() {
    union() {
      difference() {
        // Add body
        solid_body(0);
        
        // Hollow inside
        intersection() {
           solid_body(-side_wall);
          translate([0, 0, end_wall]) cylinder(d=d2, h=height-2*end_wall);
        } 
      }
      
        intersection() {
          solid_body(0);
          rings_support();
        }
      }
      
    // Cut rings
    rings_cuts();  
  }
}

inset_bottom()
//rotate([0, 0, 180])
difference() {
   main();
  if (cross_cut != 0) {
    rotate([0, 0, -90]) translate([0, -d2, -1]) cube([d2, 2*d2, 2*height]);
  }
}






