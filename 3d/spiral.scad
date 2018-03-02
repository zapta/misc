//linear_extrude(height = 3, center = false, convexity = 10, twist = 360, $fn = 100)
//translate([3, 0, 0])
//square([10, 11]);
////circle(r = 10);

//k1=5; // rotation
//k2=0.1; // height

deg_delta = 5;
height_delta = 0.2;

//function angle(i) 
//  = i*k1;
//  
//function point(i, r) =
//  let(a = angle(i))
//  [r*sin(a), r*cos(a), i*k2];
//  
//r1=2;
//r2=20;
//h=0.2;
//eps=0.1;

//r1=5;
//r2=50;

//slice_deg = 10;
//spiral_step = 2;
//slice_h_step = slice_deg * spiral_step / 360;
//w=0.1;



//kx=cos(deg_step);
//ky=sin(deg_step);


module slice(i, r1, r2, slice_deg, slice_step, w) {
  a1 = i * slice_deg;
  a2 = (i+1) * slice_deg;
  h1 = i * slice_step;
  h2 = (i + 1) * slice_step;
  
  
  
  p0 = [r1 * cos(a1), r1 * sin(a1), h1];
  p1 = [r2 * cos(a1), r2 * sin(a1), h1];
  //  echo (p1);

  p2 = [r2 * cos(a2), r2 * sin(a2), h2];
  p3 = [r1 * cos(a2), r1 * sin(a2), h2];
  
  p4 = p0 + [0, 0, w];
  p5 = p1 + [0, 0, w];
  p6 = p2 + [0, 0, w];
  p7 = p3 + [0, 0, w];
  
  points=[
    p0, p1, p2, p3, p4, p5, p6, p7
  ];

  faces = [
    // bottom
    [0, 1, 2], [0, 2, 3],
    // front
    [0, 5, 1], [0, 4, 5],
    // outer
    [1, 6, 2], [1, 5, 6],
    // back
    [2, 7, 3], [2, 6, 7], 
    // inner
    [0, 3, 7], [0, 7, 4], 
    // top
    [4, 6, 5], [4, 7, 6]
  ];

  polyhedron(points = points, faces = faces, convexity = 3);
}

module spiral(r1, r2, h, step=0.5, w=0.1, fn=24) {
  steps = h / step;
  slices = floor(steps * fn);
  slice_step = h / slices;
  slice_deg = (steps * 360) / slices;
  
  for(i=[0:slices-1]) {
    slice(i, r1, r2, slice_deg, slice_step, w);
  }
}

eps = 0.01;
$fn=64;

difference() {
  cylinder(d=30, h=30);
  translate([0, 0, -eps]) cylinder(d=20, h=30+2*eps);
  translate([0, 0, 2]) spiral(10, 20, 26, 2, 0.2);
}

