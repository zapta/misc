
//$fn=64;

h=10;
w=2;
pitchx=7;
pitchy=5;

xn = 4;
yn = 2;

for (i = [1:xn]) { 
  for (j = [1:yn]) {
    translate([(i-0.5)*pitchx-w/2, (j-0.5)*pitchy-w/2, 0]) cube([w, w, h]);
  }
} 
cube([xn*pitchx, yn*pitchy, 1]);

//translate([-10, 0, 0]) cylinder(d=d, h=h);
//translate([10, 0, 0]) cylinder(d=d, h=h);
//translate([-30/2, -10/2, 0]) cube([30, 10, 1]);

