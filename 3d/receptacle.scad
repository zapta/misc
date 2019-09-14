diameter=50;
height=100;
quality=120;
$fn=quality;
numbsides=100; rotation=0;

module hSphere(r=1,t=0.1,ns=numbsides,rot=rotation) {
	difference() {
		sphere(r);
		sphere(r-t);
	}
}
module hTorus(r=1,t=0.1,ns=numbsides,rot=rotation) {
	scale([1,1,2])difference() {
		rotate([0,0,rot]) rotate_extrude(convexity=15,$fn=ns) translate([r*2/3, 0, 0]) circle(r/3,$fn=quality); 
		rotate([0,0,rot]) scale([1,1,1.2])rotate_extrude(convexity=15,$fn=ns) translate([r*2/3, 0, 0]) circle(r/3-t,$fn=quality); 
	}
}
module nTorus(r=1,t=0.1,ns=numbsides,rot=rotation) {
	scale([1,1,2])difference() {
		rotate([0,0,rot]) rotate_extrude(convexity=15,$fn=ns) translate([r*2/3, 0, 0]) circle(r/3,$fn=quality); 
		rotate([0,0,rot]) scale([1,1,1.1])rotate_extrude(convexity=15,$fn=ns) translate([r*2/3, 0, 0]) circle(r/3-t,$fn=quality); 
	}
}

module receptacle0(ns=numbsides,rot=rotation) {
	intersection() { translate([0,0,0.5])cube(1,center=true);
		scale([1/122,1/122,1/112])translate([0,0,-2.64])difference() {
			scale([1,1,2]) translate([0,0,((30+6)*2*0.813)/2]) union() {
				difference() {
					rotate([0,0,rot]) rotate_extrude(convexity = 10,$fn=ns) translate([31, 0, 0]) circle(30,$fn=quality); 
					rotate([0,0,rot]) scale([1,1,1.08])rotate_extrude(convexity = 10,$fn=ns) translate([31, 0, 0]) circle(24,$fn=quality); 
					cylinder(31*2.5,31*1.35,31*1.35,center=true,$fn=ns);
				}
				translate([0,0,22.95])cylinder(5,31*1.352,31*1.352,$fn=ns);
				translate([0,0,0-27.95])cylinder(4.9,31*1.352,31*1.352,$fn=ns);
			}
			translate([0,0,108])cylinder(9.1,42,36,center=true,$fn=ns);
			translate([0,0,112])cylinder(9,38,41,center=true,$fn=ns);
		}
	}
}
module receptacle1(ns=numbsides,rot=rotation) {
	intersection() { translate([0,0,0.5])cube(1,center=true);
		scale([1/2,1/2,1/2])translate([0,0,0.5]) union() {
			difference() {
				hTorus(1,0.1,ns,rot);
				cylinder(1.8,0.83,0.83,center=true,$fn=ns);
			}
			scale([1.67,1.67,1]) translate([0,0,-0.5275]) cylinder(0.1,0.498,0.498,center=true,$fn=ns);
		
			difference() {
				union() {
					scale([1.67,1.67,1]) translate([0,0,0.96])  {
						intersection() {
							hTorus(1,0.1,ns,rot);
							cylinder(1.5,0.5,0.5,center=true,$fn=ns);
						}
					}
					rotate([0,0,rot]) translate([0,0,1.442])rotate_extrude(convexity = 10,$fn=ns) translate([0.83, 0, 0]) scale([0.4,1,1])circle(0.1,$fn=quality); 
				}
				union() {
					translate([0,0,0.6])cylinder(0.5,0.85,0.61,center=true,$fn=ns);
					translate([0,0,0.05])cylinder(0.6,0.85,0.85,center=true,$fn=ns);
				}
			}
		}
	}
}
module receptacle2(ns=numbsides,rot=rotation) {
	intersection() { translate([0,0,0.5])cube(1,center=true);
		scale([1/2,1/2,1/3])translate([0,0,0.5]) union() {
			difference() {
				hTorus(1,0.1,ns,rot);
				cylinder(1.8,0.83,0.83,center=true,$fn=ns);
			}
			scale([1.67,1.67,1]) translate([0,0,-0.5275]) cylinder(0.1,0.498,0.498,center=true,$fn=ns);
		
			difference() {
				scale([1,1,2]) union() {
					scale([1.67,1.67,1]) translate([0,0,0.96+((2-1)*-0.29)])  {
						intersection() {
							hTorus(1,0.1,ns,rot);
							cylinder(1.5,0.5,0.5,center=true,$fn=ns);
						}
					}
					rotate([0,0,rot]) translate([0,0,1.442+((2-1)*-0.29)])rotate_extrude(convexity = 10,$fn=ns) translate([0.83, 0, 0]) scale([0.4,1,1])circle(0.1,$fn=quality); 
				}
				union() {
					translate([0,0,0.6])cylinder(0.5,0.85,0.61,center=true,$fn=ns);
					translate([0,0,0.05])cylinder(0.6,0.85,0.85,center=true,$fn=ns);
				}
			}
		}
	}
}
module receptacle3(ns=numbsides,rot=rotation) {
	intersection() { translate([0,0,0.5])cube(1,center=true);
		scale([1/2,1/2,1/1.75])translate([0,0,0.5]) union() {
			difference() {
				hTorus(1,0.1,ns,rot);
				cylinder(1.8,0.83,0.83,center=true,$fn=ns);
			}
			scale([1.67,1.67,1]) translate([0,0,-0.5275]) cylinder(0.1,0.498,0.498,center=true,$fn=ns);
		
			difference() {
				scale([1,1,0.7]) union() {
					scale([1.67,1.67,1]) translate([0,0,1.215])  {
						intersection() {
							hTorus(1,0.1,ns,rot);
							cylinder(1.5,0.5,0.5,center=true,$fn=ns);
						}
					}
					rotate([0,0,rot]) translate([0,0,1.697])rotate_extrude(convexity = 10,$fn=ns) translate([0.83, 0, 0]) scale([0.4,1,1])circle(0.1,$fn=quality); 
				}
				union() {
					translate([0,0,0.6])cylinder(0.5,0.85,0.61,center=true,$fn=ns);
					translate([0,0,0.05])cylinder(0.6,0.85,0.85,center=true,$fn=ns);
				}
			}
		}
	}
}
module receptacle4(ns=numbsides,rot=rotation) {
	intersection() {
		scale([0.5,0.5,0.47])translate([0,0,0.57]) union() {
			difference() {
				hTorus(1,0.1,ns,rot);
				translate([0,0,-1.38])cylinder(1.8,0.83,0.83,center=true,$fn=ns);
				cylinder(1.8,0.65,0.65,center=true,$fn=ns);
				translate([0,0,0.5])cylinder(1,1.1,1.1,center=true,$fn=ns);
			}
			scale([1.67,1.67,1]) translate([0,0,-0.5275]) cylinder(0.1,0.498,0.498,center=true,$fn=ns);
			translate([0,0,0.75])difference() {
				cylinder(1.5,1,1,center=true,$fn=ns);
				cylinder(2,0.9,0.9,center=true,$fn=ns);
			}
			rotate([0,0,rot]) translate([0,0,1.5])rotate_extrude(convexity = 10,$fn=ns) translate([0.95, 0, 0]) circle(0.05,$fn=quality); 
		}
		translate([0,0,0.5]) cube(1,center=true);
	}
}
module receptacle5(ns=numbsides,rot=rotation) {
	intersection() {
		scale([0.39,0.39,0.445])translate([0,0,0.5752]) union() {
			difference() {
				hTorus(1,0.1,ns,rot);
				translate([0,0,-1.38])cylinder(1.8,0.83,0.83,center=true,$fn=ns);
				cylinder(1.8,0.65,0.65,center=true,$fn=ns);
				translate([0,0,0.5])cylinder(1,1.1,1.1,center=true,$fn=ns);
			}
			scale([1.67,1.67,1]) translate([0,0,-0.5275]) cylinder(0.1,0.498,0.498,center=true,$fn=ns);
			translate([0,0,0.5])difference() {
				cylinder(1,1,1,center=true,$fn=ns);
				cylinder(2,0.9,0.9,center=true,$fn=ns);
			}
			rotate([0,0,rot]) translate([0,0,1.61])rotate_extrude(convexity = 10,$fn=ns) translate([1.24, 0, 0]) scale([1,3,1])circle(0.025,$fn=quality); 
			scale([2.515,2.515,2])translate([0,0,0.25]) intersection() {
					nTorus(1,0.041,ns,rot);
					cylinder(1.5,0.5,0.5,center=true,$fn=ns);
					translate([0,0,0.5])cylinder(0.5,1,1,center=true,$fn=ns);
				}
		}
		translate([0,0,0.5]) cube(1,center=true);
	}
}
module receptacle6(ns=numbsides,rot=rotation) {
	intersection() {
		scale([0.39,0.39,0.57])translate([0,0,0.5752]) union() {
			difference() {
				hTorus(1,0.1,ns,rot);
				translate([0,0,-1.38])cylinder(1.8,0.83,0.83,center=true,$fn=ns);
				cylinder(1.8,0.65,0.65,center=true,$fn=ns);
				translate([0,0,0.5])cylinder(1,1.1,1.1,center=true,$fn=ns);
			}
			scale([1.67,1.67,1]) translate([0,0,-0.5275]) cylinder(0.1,0.498,0.498,center=true,$fn=ns);
			translate([0,0,0.25])difference() {
				cylinder(0.5,1,1,center=true,$fn=ns);
				cylinder(2,0.9,0.9,center=true,$fn=ns);
			}
			rotate([0,0,rot]) translate([0,0,1.11])rotate_extrude(convexity = 10,$fn=ns) translate([1.24, 0, 0]) scale([1,3,1])circle(0.025,$fn=quality); 
			scale([2.515,2.515,2])translate([0,0,0]) intersection() {
					nTorus(1,0.041,ns,rot);
					cylinder(1.5,0.5,0.5,center=true,$fn=ns);
					translate([0,0,0.5])cylinder(0.5,1,1,center=true,$fn=ns);
				}
		}
		translate([0,0,0.5]) cube(1,center=true);
	}
}
module receptacle7(ns=numbsides,rot=rotation) {
	intersection() {
		scale([0.39,0.39,0.8])translate([0,0,0.5752]) union() {
			difference() {
				hTorus(1,0.1,ns,rot);
				translate([0,0,-1.38])cylinder(1.8,0.83,0.83,center=true,$fn=ns);
				cylinder(1.8,0.65,0.65,center=true,$fn=ns);
				translate([0,0,0.5])cylinder(1,1.1,1.1,center=true,$fn=ns);
			}
			scale([1.67,1.67,1]) translate([0,0,-0.5275]) cylinder(0.1,0.498,0.498,center=true,$fn=ns);
			rotate([0,0,rot]) translate([0,0,0.61])rotate_extrude(convexity = 10,$fn=ns) translate([1.24, 0, 0]) scale([1,3,1])circle(0.025,$fn=quality); 
			scale([2.515,2.515,2])translate([0,0,-0.25]) intersection() {
					nTorus(1,0.041,ns,rot);
					cylinder(1.5,0.5,0.5,center=true,$fn=ns);
					translate([0,0,0.5])cylinder(0.5,1,1,center=true,$fn=ns);
				}
		}
		translate([0,0,0.5]) cube(1,center=true);
	}
}
module receptacle8(ns=numbsides,rot=rotation) {
	intersection() {
		scale([0.5,0.5,0.48])translate([0,0,0.5]) union() {
			translate([0,0,0.25])difference() {
				cylinder(1.5,1,1,center=true,$fn=ns);
				cylinder(2,0.9,0.9,center=true,$fn=ns);
			}
			translate([0,0,-0.45]) cylinder(0.1,1,1,center=true,$fn=ns);
			translate([0,0,1])rotate([180,0,0])difference() {
				hTorus(1,0.1,ns,rot);
				translate([0,0,-1.25])cylinder(1.8,0.83,0.83,center=true,$fn=ns);
				cylinder(1.8,0.65,0.65,center=true,$fn=ns);
				translate([0,0,0.5])cylinder(1,1.1,1.1,center=true,$fn=ns);
			}
			rotate([0,0,rot]) translate([0,0,1.493])rotate_extrude(convexity = 10,$fn=ns) translate([0.83, 0, 0]) scale([1,3.5,1])circle(0.025,$fn=quality); 
		}
		translate([0,0,0.5]) cube(1,center=true);
	}
}

module receptacle9(ns=numbsides,rot=rotation) {
	intersection() {
		scale([0.5,0.5,0.48])translate([0,0,0.5]) union() {
			translate([0,0,0.25])difference() {
				cylinder(2.5,1,1,center=true,$fn=ns);
				cylinder(2.6,0.9,0.9,center=true,$fn=ns);
			}
			translate([0,0,-0.45]) cylinder(0.1,1,1,center=true,$fn=ns);
			rotate([0,0,rot]) translate([0,0,1.5])rotate_extrude(convexity = 10,$fn=ns) translate([0.95, 0, 0]) circle(0.05,$fn=quality); 
		}
		translate([0,0,0.5]) cube(1,center=true);
	}
}

module all() {
	distance=1;
	offset=-4;
	scale(50) {
		translate([offset+distance*0,0,0]) {
			receptacle3(); 
			translate([0,distance*1,0])receptacle3(3,30);
			translate([0,distance*2,0])receptacle3(4,0);
			translate([0,distance*3,0])receptacle3(5,-18);
			translate([0,distance*4,0])receptacle3(6,30);
		}
		translate([offset+distance*1,0,0]) {
			receptacle1(); 
			translate([0,distance*1,0])receptacle1(3,30);
			translate([0,distance*2,0])receptacle1(4,0);
			translate([0,distance*3,0])receptacle1(5,-18);
			translate([0,distance*4,0])receptacle1(6,30);
		}
		translate([offset+distance*2,0,0]) {
			receptacle2(); 
			translate([0,distance*1,0])receptacle2(3,30);
			translate([0,distance*2,0])receptacle2(4,0);
			translate([0,distance*3,0])receptacle2(5,-18);
			translate([0,distance*4,0])receptacle2(6,30);
		}
		translate([offset+distance*3,0,0]) {
			receptacle0(); 
			translate([0,distance*1,0])receptacle0(3,30);
			translate([0,distance*2,0])receptacle0(4,0);
			translate([0,distance*3,0])receptacle0(5,-18);
			translate([0,distance*4,0])receptacle0(6,30);
		}
		translate([offset+distance*4,0,0]) {
			receptacle4(); 
			translate([0,distance*1,0])receptacle4(3,30);
			translate([0,distance*2,0])receptacle4(4,0);
			translate([0,distance*3,0])receptacle4(5,-18);
			translate([0,distance*4,0])receptacle4(6,30);
		}
		translate([offset+distance*5,0,0]) {
			receptacle8(); 
			translate([0,distance*1,0])receptacle8(3,30);
			translate([0,distance*2,0])receptacle8(4,0);
			translate([0,distance*3,0])receptacle8(5,-18);
			translate([0,distance*4,0])receptacle8(6,30);
		}
		translate([offset+distance*6,0,0]) {
			receptacle9(); 
			translate([0,distance*1,0])receptacle9(3,30);
			translate([0,distance*2,0])receptacle9(4,0);
			translate([0,distance*3,0])receptacle9(5,-18);
			translate([0,distance*4,0])receptacle9(6,30);
		}
		translate([offset+distance*7,0,0]) {
			receptacle5(); 
			translate([0,distance*1,0])receptacle5(3,30);
			translate([0,distance*2,0])receptacle5(4,0);
			translate([0,distance*3,0])receptacle5(5,-18);
			translate([0,distance*4,0])receptacle5(6,30);
		}
		translate([offset+distance*8,0,0]) {
			receptacle6(); 
			translate([0,distance*1,0])receptacle6(3,30);
			translate([0,distance*2,0])receptacle6(4,0);
			translate([0,distance*3,0])receptacle6(5,-18);
			translate([0,distance*4,0])receptacle6(6,30);
		}
		translate([offset+distance*9,0,0]) {
			receptacle7(); 
			translate([0,distance*1,0])receptacle7(3,30);
			translate([0,distance*2,0])receptacle7(4,0);
			translate([0,distance*3,0])receptacle7(5,-18);
			translate([0,distance*4,0])receptacle7(6,30);
		}
	}
}
module sides() {
	angle=360/14;
	distance=2.5;
	scale(50) {
		receptacle1();
		rotate([0,0,angle*0])translate([distance,0,0])receptacle1(3,30);
		rotate([0,0,angle*1])translate([distance,0,0])receptacle1(4,0);
		rotate([0,0,angle*2])translate([distance,0,0])receptacle1(5,-18);
		rotate([0,0,angle*3])translate([distance,0,0])receptacle1(6,30);
		rotate([0,0,angle*4])translate([distance,0,0])receptacle1(7,90/7);
		rotate([0,0,angle*5])translate([distance,0,0])receptacle1(8,0);
		rotate([0,0,angle*6])translate([distance,0,0])receptacle1(9,-10);
		rotate([0,0,angle*7])translate([distance,0,0])receptacle1(10,18);
		rotate([0,0,angle*8])translate([distance,0,0])receptacle1(11,90/11);
		rotate([0,0,angle*9])translate([distance,0,0])receptacle1(12,0);
		rotate([0,0,angle*10])translate([distance,0,0])receptacle1(13,-90/13);
		rotate([0,0,angle*11])translate([distance,0,0])receptacle1(14,90/7);
		rotate([0,0,angle*12])translate([distance,0,0])receptacle1(15,6);
		rotate([0,0,angle*13])translate([distance,0,0])receptacle1(20,0);
	}
}
//all();
//sides();

scale(100) receptacle9(9,-10);

