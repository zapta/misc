$fn=32;

// Gopro connector based on http://www.thingiverse.com/thing:62800

// The locking nut on the gopro mount triple arm mount (keep it tight)
gopro_nut_d= 9.2;

// How deep is this nut embossing (keep it small to avoid over-overhangs)
gopro_nut_h= 2;

// Hole diameter for the 3-arm mount part
gopro_holed_three= 5.5;

// Thickness of the internal arm in the 3-arm mount part
gopro_connector_th3_middle= 3.1;

// Thickness of the side arms in the 3-arm mount part
gopro_connector_th3_side= 2.7;

// The gap in the 3-arm mount part for the two-arm
gopro_connector_gap= 3.1;

// How round are the 2 and 3-arm parts
gopro_connector_roundness= 1;

// How thick are the mount walls
gopro_wall_th= 3;

gopro_connector_wall_tol=0.5+0;
gopro_tol=0.04+0;

gopro_connector_z = (2 * gopro_connector_th3_side) + gopro_connector_th3_middle + (2 * gopro_connector_gap);
gopro_connector_x = gopro_connector_z;
gopro_connector_y = (gopro_connector_z / 2) + gopro_wall_th;

module gopro_torus(r,rnd)
{
	translate([0,0,rnd/2])
		rotate_extrude(convexity= 10)
			translate([r-rnd/2, 0, 0])
				circle(r= rnd/2, $fs=0.2);
}

// th = thickness.
module gopro_tab(th)
{
  hull()
  {
    // Bottom edge
    gopro_torus(r=gopro_connector_z/2, rnd=gopro_connector_roundness);
    
    // Top edge
    translate([0,0,th-gopro_connector_roundness])
      gopro_torus(r=gopro_connector_z/2, rnd=gopro_connector_roundness);
    
    // flat base
    translate([-gopro_connector_z/2, gopro_connector_z/2 + gopro_wall_th ,0])
      cube([gopro_connector_z*2, gopro_tol, th]);
    
//        #translate([-gopro_connector_z/2,gopro_connector_z/2,0])
//      cube([gopro_connector_z*(3/2), gopro_wall_th, th]);
  }
}
  
module gopro_connector() {
	difference() {
		union() {    
      // Center tab
      translate([0,0,-gopro_connector_th3_middle/2]) 
          gopro_tab(gopro_connector_th3_middle);
    
      // Tow side tabs
      for(mz=[-1:2:+1]) scale([1,1,mz]) {
        translate([0,0,gopro_connector_th3_middle/2 + gopro_connector_gap]) 
          gopro_tab(gopro_connector_th3_side);
      }

			// add the common wall
//		#translate([0,gopro_connector_z/2+gopro_wall_th/2+gopro_connector_wall_tol,0])
//				cube([gopro_connector_z,gopro_wall_th,gopro_connector_z], center=true);

			// add the optional nut emboss
    translate([0,0,gopro_connector_z/2-gopro_tol])
      difference() {
        cylinder(r1=gopro_connector_z/2-gopro_connector_roundness/2, r2=11.5/2, h=gopro_nut_h+gopro_tol);
        cylinder(r=gopro_nut_d/2, h=gopro_connector_z/2+3.5+gopro_tol, $fn=6);
      }
		}
    
		// remove the center hole
		translate([0,0,-gopro_tol])
			cylinder(d=gopro_holed_three, h=gopro_connector_z+4*gopro_tol, center=true, $fs=1);
	}
}

rotate([0, 90, 0]) rotate([-90, 0, 0]) gopro_connector();

translate([-15, -10, -23]) cube([5, 20, 31]);

translate([-15, -10, -27]) cube([10, 20, 4]);

//gopro_tab(3);

