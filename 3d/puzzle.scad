// sphere puzzle 2 (new tolerance)

$fn=360;

R=30; // radius of sphere
tol=0;//0.5;// tolerance to allow looser fit
x=R*cos(45);


module inset_bottom(w=0.4, h=0.2, bounding_size = 200, eps=0.01) {
  if (w == 0 || h < 0) {
    children();
  } else {
    // The top part of the children without the inset layer.
    difference() {
      children();
      // TODO: use actual extended children projection instead
      // of a clube with arbitrary large x,y values.
      translate([0, 0, -9*h])
          cube([bounding_size, bounding_size, 20*h], center=true);
    }
    // The inset layer.
    linear_extrude(height=h+eps) offset(r = -w) projection(cut=true)
      children();
  }
}

inset_bottom()
translate([0, 0, 21.21])
rotate([-90,0,])
difference(){
	sphere(r=R);
	translate([0,0,-R])
		cube(size=[R,2*R,2*R+tol],center=true);
	translate([0,-R,0])
		cube(size=[R,2*R+tol,2*R],center=true);
	rotate([-45,0,0])
		translate([0,0,-2*R])
			cube(size=4*R,center=true);
	translate([0,0,R+x])
		cube(size=2*R+tol,center=true);
	translate([0,R+x,0])
		cube(size=2*R+tol,center=true);
	translate([R/2,0,0])
		rotate([-45,0,0])rotate([0,45,0])
			cube(size=[x+tol,2*R,x+tol],center=true);
	translate([-R/2,0,0])
		rotate([-45,0,0])rotate([0,45,0])
			cube(size=[x+tol,2*R,x+tol],center=true);
	translate([0,-x+2*tol,0])
		rotate([45,0,0])translate([0,0,R/2])
			cube(size=[R,2*R,R],center=true);
	translate([0,0,-x+2*tol])
		rotate([45,0,0])translate([0,0,-R/2])
			cube(size=[R,2*R,R],center=true);
}