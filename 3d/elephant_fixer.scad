// An OpenScad script that demonstrates how to inset the bottom of
// arbitrary objects that are placed on the z=0 plane. This is useful
// to avoid the 'elephant feet' effect when the first layer(s) of 
// a 3D print are squashed out of the object's outline.

// Test ring roundness
$fn=128;

// How much to inset the bottom.
inset_width = 0.4;

// How high to inset the bottom.  
inset_height = 0.4;

// The inner diameter of the test ring.
test_ring_id = 20;

// The width of the test ring.
test_ring_width = 5;

// The height of the test ring.
test_ring_height = 3;

// Elevation of the ring above z=0 plane. Negative value
// lowers the bottom of the test ring below the z=0 plane. 
// 
// It's safer to have the base of the object slightly below the 
// z=0 plane than above it as it prevents the 'projection failed' 
// OpenScad error.
test_ring_elevation = 0.0;

// The inset function. The inset object(s) must be positioned
// exactly or slightly below the z=0 plane. As of March 2017,
// OpenScad doesn't allow to uery the position of the children.
//
// NOTE: a 'projection failed' error indicates that the inset
// object(s) do not intersect with the z=0 plane. It's safer to 
// position the children slightly below the z=0 plane (e.g. 
// by 0.01mm) to be on the safe side.
// 
// w = how much to inset.
// h = how high, from the z=0 plane, to inset.
// bounding_size = a large number, larger than max x and max y
//     of the inset object. Default should be good for more 3D
//     printing applications.
// eps = a small number to maintain manifold. Default should be 
//     good for most 3D printing applications.
module inset_bottom(w=0.4, h=0.2, bounding_size = 200, eps=0.01) {
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

// A test object. We use a ring but the the inset_bottom() function
// should handle arbitrary objects as long as they are placed on the 
// z=0 plane or slightly below.
module test_ring() {
  difference() {
    cylinder(d=test_ring_id+2*test_ring_width, h=test_ring_height);
    translate([0, 0, -0.01]) cylinder(d=test_ring_id, h=test_ring_height+0.02);
  }  
}

// Demonstration how to call the inset_bottom() module  to inset
// the bottom of an object placed on the z=0 plane. 
// We speciy here explicit w and h to allow Thingiverse Customizer
// users play with the inset parameters.
inset_bottom(inset_width, inset_height) 
    translate([0, 0, test_ring_elevation]) test_ring();