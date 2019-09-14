
$fn=0+40;

// Diameter of magnet cavity. Make it slightly wider than your magnet.
magnet_cavity_diameter = 9.5;

// Height of magnet cavity. If you attach the magnet with a drop of super glue making it much longer than the magnet is ok.
magnet_cavity_height = 12;

// The thickness of the magnet cavity base. Higher values means less magnetic attraction.
magnet_base_thickness = 0.6;

// Vertical offset of the cat's body. Determine the shape of the base and easy of printing.
cat_vertical_offset = -2.5;

// Cat scale factor.
cat_body_scale = 1;

// 'false' for printing, 'true' for examining the model.
cross_cut = false;

// Normalized scale.
//k = 0.5 * cat_body_scale;

// Larger than any dimension. 
large = 0+100;

module main() {
  difference() {
    //union() {
      //intersection() {
        //scale(k) 
          //translate([-13, 0, cat_vertical_offset]) 
    translate([10, -4, 9.504])
          scale(1.5)
          rotate([90, 0, 0])
          import("base_gecko_model.stl", convexity=10);

        // Remove cat bottom below z=0
        //cylinder(d=large, h=large);
      //}
    //}

//    // Magnet cavity 1 (tail)
   translate([12, -0.5, magnet_base_thickness]) 
      #cylinder(d=magnet_cavity_diameter, h=magnet_cavity_height);  //0.6  9.5
    
          // Magnet cavity 2 (center)
   translate([-0.5, 1, magnet_base_thickness])       #cylinder(d=magnet_cavity_diameter, h=magnet_cavity_height);  //0.6  9.5

    
      // Magnet cavity 3 (head)
   translate([-13, 0.4, magnet_base_thickness])       #cylinder(d=magnet_cavity_diameter, h=magnet_cavity_height);  //0.6  9.5
    
  }
}

//intersection() {
  mirror([0, 1, 0])
    main();
//  translate([-22, -10, 0])
//  cube([44, 20, 12]);
//}



