// CoreXY printer test
//
// Allows to compare quality of horizontal/vertical lines vs
// diagonal lines.

l=20;
w=1.6;
h = 10;

w2=w/2;
k=1/sqrt(2);
lk = l*k;
wk = w*k;

outer_points = [
  [2*lk, 0], 
  [0, 0], 
  [0, l], 
  [lk, l+lk], 
  [2*lk, l ]
];

inner_points = [
  outer_points[0]+[-w, w],
  outer_points[1]+[w, w],
  outer_points[2]+[w, -w*tan(22.5)],
  outer_points[3]+[0, -w/k],
  outer_points[4]+[-w, -w*tan(22.5)] 
];

linear_extrude(height = h)
  difference() {
    polygon(outer_points);
    polygon(inner_points);
  }