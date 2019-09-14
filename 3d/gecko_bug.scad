// simplify gecko model to avoid CGAL error (?)

 difference() {
 translate([10, -4, 9.504])
          scale(1.5)
          rotate([90, 0, 0])
          import("base_gecko_model.stl", convexity=10);

   // Gecko appears when this is commented out
  //// translate([16, -1.5, -0.6]) 
   //    #cylinder(d=9.5, h=11);  
}

