w=0.2;
h = 1;
s = 0.5;

module point(p) {

  translate([p[0], p[1], 0])
  cylinder(d=w, h=h);
}

module line(p1, p2) {

  hull() {
    point(p1);
    point(p2);
  }
}

path = 
[ 
  [23, 5+s], 
  [0, 5+s],
  [0, 0],
  [5, 0],
  [5, 5],
  [10, 5],
  [10, 0],
  [20, 0],
  [20, 5],
  [15, 5],
  [15, 2]
];

#translate([2, 2, 0.2-0.01])
for (i = [0 : len(path) -2]) {
  line(path[i], path[i+1]);
}

cube([26, 10, 0.2]);