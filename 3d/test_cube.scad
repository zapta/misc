
dx=30;
dy=20;
wall=1.2;
h = 10;

difference() {
translate([-dx/2, -dy/2, 0])
cube([dx, dy, h]);
  
  translate([-dx/2+wall, -dy/2+wall, -0.01])
  cube([dx-2*wall, dy-2*wall, h+0.02]);
}