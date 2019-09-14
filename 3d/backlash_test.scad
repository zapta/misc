w = 1; 
xstep = 3;
ystep = 10;
base_height=0.2;
snake_height=0.2;

module vline(i) {
  x = i * xstep;
  
    dy = (i % 4) >= 2 ? -ystep : 0;
    translate([x-w/2, dy, 0])
      cube([w, ystep, snake_height]);
}

module hline(i) {
  x = i * xstep;
  
   dy = [ystep, 0, -ystep, 0][(i % 4)];
  translate([x-w/2, dy-w/2, 0])
    cube([xstep+w, w, snake_height]);  
}

module snake() {
for(i = [0:17]) {
  vline(i);
  hline(i);
}
}

translate([3, 0, base_height])
#snake();

translate([0, -12, 0])
cube([60, 24, base_height+0.001]);