$fn=90;

post_height = 60;
post_diameter = 10;
ball_diameter = 15;

cylinder(d=post_diameter, h=post_height-ball_diameter/2);
translate([0, 0, post_height-ball_diameter/2]) sphere(d=ball_diameter);

hull() {
cylinder(d=20, h=5);
translate([0, 35, 0]) cylinder(d=35, h=5);
}

translate([0, 0, 5-0.01]) cylinder(d1=post_diameter+6, d2=post_diameter-0.01, h=4);