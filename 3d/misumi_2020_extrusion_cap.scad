$fn=64;

slot_width=6;
slot_thickness=2;

t_width=6;
t_depth=2;

trap_bot_width=11;
trap_top_width=5;
trap_depth=2.5;

extrusion_width=20;
cover_thickness=2;
corner_rounding=2;
hole_size=0;

tab_height=cover_thickness+6;

undersize=0.18;			//this may need be adjusted for a good fit

difference() {
	union() {
		for (a=[0:2])
			rotate([0,0,90*a])
				translate([0,-extrusion_width/2,0])
					#t_slot();
		
		translate([-extrusion_width/2+corner_rounding, -extrusion_width/2+corner_rounding,0])
			minkowski() {
				cube([extrusion_width-corner_rounding*2,extrusion_width-corner_rounding*2,cover_thickness-1]);
				cylinder(r=corner_rounding, h=1);
			}
	}
	cylinder(r=hole_size/2, h=cover_thickness*4, center=true);
}

module t_slot() {
	translate([-slot_width/2+undersize/2,0,0])
		cube([slot_width-undersize, slot_thickness+t_depth, tab_height]);
	translate([-t_width/2+undersize/2,slot_thickness,0])
		cube([t_width-undersize,t_depth-undersize+0.01,tab_height]);
	translate([0,slot_thickness+t_depth-undersize,0])
		linear_extrude(height=tab_height)
			trapezoid(bottom=trap_bot_width-undersize, top=trap_top_width-undersize, height=trap_depth-undersize);
}


module trapezoid(bottom=10, top=5, height=2)
{
	polygon(points=[[-bottom/2,0],[bottom/2,0],[top/2,height],[-top/2,height]]);
}
