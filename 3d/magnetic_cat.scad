
$fn=0+40;

// Diameter of magnet cavity. Make it slightly wider than your magnet.
magnet_cavity_diameter = 9.5;

// Height of magnet cavity. If you attach the magnet with a drop of super glue making it much longer than the magnet is ok.
magnet_cavity_height = 25;

// The thickness of the magnet cavity base. Higher values means less magnetic attraction.
magnet_base_thickness = 0.6;

// Vertical offset of the cat's body. Determine the shape of the base and easy of printing.
cat_vertical_offset = -2.5;

// Cat scale factor.
cat_body_scale = 1;

// 'false' for printing, 'true' for examining the model.
cross_cut = false;

// Normalized scale.
k = 0.5 * cat_body_scale;

// Larger than any dimension. 
large = 0+200;

module main() {
  difference() {
    union() {
      intersection() {
        scale(k) 
          translate([-13, 0, cat_vertical_offset]) 
          import("my_fat_cat.stl", convexity=3);

        // Remove cat bottom below z=0
        cylinder(d=large, h=large);
      }
    }

    // Magnet cavity
    translate([0, 0, magnet_base_thickness]) cylinder(d=magnet_cavity_diameter, h=magnet_cavity_height);  //0.6  9.5
  }
}

difference() {
  main();
  if (cross_cut) {
    translate([0, -large, -1]) cube([large, large, large]);
  }
}
