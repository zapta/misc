
$fn=128;



d1=10;
h1=50; //  40  50  60 original 67  

d2=6.8;
h2=12;

eps=0.01;


cylinder(d=d1, h=h1);

translate([0, 0, h1-eps]) cylinder(d=d2, h=h2+eps);
