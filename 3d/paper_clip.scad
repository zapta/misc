
strip_height = 5;
strip_width = 5;
total_width = 32;
total_length = 100;
margin = 1;

// Total dimensions translated to centerlines
cl_width = total_width - strip_width;
cl_length = total_length - strip_width;

// Length of the outer end as a fraction of total length
k1=0.60;
// Length of the inner loop as a fraction of total length
k2=0.65;
// Length of the inner end as a fraction of total length;
k3=0.55;

$fn=128+0;

d1 = cl_width;
d2 = d1 - strip_width - margin;
d3 = d2 - strip_width - margin;

r1 = d1/2;
r2 = d2/2;
r3 = d3/2;

l1 = cl_length - r1 - r2;
l2 = total_length * k2;
l3 = total_length * k3;

eps1=0.01+0;
eps2=2*eps1;

// R is measured at center line.
module arc(r) {
  difference() {
    cylinder(r=r+strip_width/2, h=strip_height);
    translate([0, 0, -eps1]) cylinder(r=r-strip_width/2, h=strip_height+ eps2);
    translate([-1.5*r, -2*r, -eps1]) cube([3*r, 2*r, strip_height+ eps2]);
  }  
}

module bar(l) {
  translate([-strip_width/2, -eps1, 0]) cube([strip_width, l+2*eps1, strip_height]);  
}

translate([2*r1, r1, 0]) bar(k1*total_length);

translate([r1, r1, 0]) mirror([0, 1, 0]) arc(r1);

translate([0, r1, 0]) bar(l1);

translate([r2, r1 + l1, 0]) arc(r2);

translate([2*r2, r1+l1-l2, 0 ])bar(l2);

translate([d2-r3, r1+l1-l2, 0]) mirror([0, 1, 0]) arc(r3);

translate([strip_width + margin, r1+l1-l2, 0]) bar(l3);
  
  