k=2.27;

intersection() {
  scale([k, k, k]) 
  rotate([0, 0, -90])
  translate([0, 0, -0.9]) 
    import("FatCat2_fixed.stl", convexity=3);

  cylinder(d=130, h=70);
}

