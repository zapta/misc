$fn=64;

module blank() {
  import("geckoz_curved.stl", convexity=3);

  linear_extrude(height=5)
    polygon([
      [-36, -39],
      [-38, -45],
      [-37, -50],
      [-32, -60],
      [-29, -60],
      [-22, -50],
      [-21, -45],
      [-22, -41],
      [-26, -43],
      [-29, -44],
      [-32, -43],
      ]);
    
  linear_extrude(height=5)
  polygon([
      [-22, -9],
      [-19, -9.5],
      [-13.5, -12],
      [-8, -3],
      [-14, 2],
      [-15, 4],
      [-20, 4],
      [-25, 6],
      [-29, -3],
      ]);
}

difference() {
    blank();
  
    // Magnet cavities
    translate([-19.4, -3.4, 0.6])
    cylinder(d=9.5, h=5);
  
    translate([-29.9, -50, 0.6])
    cylinder(d=9.5, h=5);
  
    // Manifold releases for Simplify3D mesh seperation.
    translate([-29.1, -43.4, 3.5]) rotate([0, 0, -8]) rotate([90,0,0]) #cylinder(d=0.1, h=5);
  
    translate([-11.5, 2, 3.5]) rotate([0, 0, -45]) rotate([90,0,0]) #cylinder(d=0.1, h=8);
}

    
 
    
  