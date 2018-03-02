
// Brompton headset gopro mount.

$fn=100;


base_length = 55;

base_width = 28;


base_height = 23;

// Block corner radius
corner=4;

stem_diameter = 37;

stem_radius = stem_diameter/2;

side_margin = 2;

screw_space = 26;
screw_hole_diameter = 5.5;

stem_depth = stem_radius*(1 - cos(asin((base_width/2-side_margin)/stem_radius)));

eps1 = 0.01;
eps2 = eps1*2;

//========== START GOPRO CODE

// Gopro connector, based on http://www.thingiverse.com/thing:62800

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

gopro_filet = 2;

module gopro_torus(r,rnd)
{
	translate([0,0,rnd/2])
		rotate_extrude(convexity= 10)
			translate([r-rnd/2, 0, 0])
				circle(r= rnd/2, $fs=0.2);
}

// This lowers the gopro tabs into the brompton base body.
gopro_tab_filet_offset= 2;

module gopro_tab_filet(th) {
  f = gopro_filet;
  dx = gopro_connector_z+2*f;
  dy = th+2*f;
  translate([0, gopro_connector_z/2 + gopro_wall_th+gopro_tol-gopro_tab_filet_offset ,th/2])
  rotate([90, 0, 0])
  difference() {
    translate([-dx/2, -dy/2, 0])
      cube([dx, dy, f]);
    
   for (side = [0:1]) {
      mirror([0, side, 0]) 
        translate([-dx/2-1, -dy/2, f]) 
           rotate([0, 90, 0]) cylinder(r=f, h=dx+2);
     
        mirror([side, 0, 0])
          translate([-dx/2, dy/2+1, f]) 
             rotate([90, 0, 0]) cylinder(r=f, h=dy+2);
    }
  }
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
      cube([gopro_connector_z, gopro_tol, th]);
   }
   
   // Filet
   gopro_tab_filet(th);
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

module gopro_main() {
rotate([-90, 0, 0]) 
translate([0, -gopro_connector_z/2-gopro_wall_th, 0]) 
gopro_connector();
}

//========== END GOPRO CODE

module block() {
   r1 = corner;
   r2 = 5;
   length_inset = 4;
   width_inset = 1;
   hull()
   for (mirrors = [[0, 0], [0, 1], [1, 0], [1, 1]]) {
     mirror([mirrors[0], 0, 0]) 
     mirror([0, mirrors[1], 0]) {
       translate([base_length/2-r1, base_width/2-r1, 0]) cylinder(r=r1, h=eps1);
  
      translate([base_length/2-r2-length_inset, base_width/2-r2-width_inset, base_height-r2]) sphere(r=r2);
    }
  }  
}

module main() {
  
  difference() {
    union() 
    {
      // Add block
     // rounded_surface(base_length, base_width, base_height, corner);
      block();
        
        // Add gopro connector
      translate([0, 0, base_height-gopro_tab_filet_offset-eps1]) gopro_main();
    }
 
    // Remove round stem
    // NOTE: this is a larger radius so using higher $fn.
    translate([-base_length/2-eps1, 0, -stem_diameter/2+stem_depth]) rotate([0, 90, 0]) 
        cylinder(d=stem_diameter, h=base_length+eps2, $fn=2*$fn);
  
    // Remove center cavity
    translate([-43/2, -9/2, -eps1]) cube([43, 9, 13+eps1]);
  
      // Remove secondary cavity.
    hull() {
      translate([-43/2, -16/2, -eps1]) cube([43, 16, 4]);
      translate([-43/2, -9/2, -eps1]) cube([43, 9, 10]);
    }
    
    // Remove screw holes
    for (side = [0:1]) {
      mirror([side, 0, 0]) translate([screw_space/2, 0, 0]) {
       // Screw hole
       translate([0, 0, -eps1])
         cylinder(d=screw_hole_diameter, h=base_height+eps2);  
       
       // Screw hole head clearance
       translate([0, 0, base_height-eps1]) 
         cylinder(d=11.3, h=6);
      }
    }
  }
}

//block();

main();


//gopro_tab(gopro_connector_th3_middle);
