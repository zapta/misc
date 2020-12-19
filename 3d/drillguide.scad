// Drillguide and sawduct collector for drilling on wall
// By Leo Liang, 2018-7-28
//
// Remix on https://www.thingiverse.com/thing:3013962, by Coat, 08-jul-2018
// Licensed under the Creative Commons - Attribution license.

//Primary parameters
//diameter drill (mm), add a little tolerance
drill_diameter = 8.2;
//height of the  guidetube (mm)
guide_height = 35;
//width of the guidetube (mm)
guide_diameter = 16;
//thickness of the baseplate (mm)
plate_thick = 3;
//width of the baseplate (mm)
plate_width = 80;
// width of the sawdust collector (mm)
collector_width = 80; 
//depth of the sawdust collector (mm)
collector_depth = 30; 
//height of the sawdust collector (mm)
collector_height = 35; 
// thickness of the wall of the collector (mm)
collector_thick = 1;

module plate(w,t)
{
  translate([0,0,0.5 * plate_thick]) difference()
  {
    cube([w, w, t], center=true);
    cube([w/1.25, guidlinew, guide_height],center = true);
    cube([guidlinew, w/1.25, guide_height],center = true);
    
    translate([0.5*plate_width,0,-plate_thick/2])
      nodge();
    translate([0,0.5*plate_width,-plate_thick/2])
      nodge();
    translate([-0.5*plate_width,0,-plate_thick/2])
      nodge();
  }
} 

module nodge()
{
  translate([0,0,plate_thick/2]) rotate([0,0,45])
    cube([3,3,plate_thick+0.01], center=true);
}

module collector() {
  offset = min(collector_height, (plate_width-guide_diameter)/2);
  depth = collector_depth + offset;
  difference() {
    translate([0, offset/2, collector_height/2]) cube([collector_width, depth, collector_height], center=true);
    translate([0, offset/2+collector_thick, collector_height/2])
      cube([collector_width-collector_thick*2, depth, collector_height-collector_thick*2], center=true);
  	multmatrix(m=[[1, 0, 0, -collector_width/2-1],
  								[0, 1, -offset/collector_height, collector_depth/2+offset],
	  							[0, 0, 1, 0],
		  						[0, 0, 0, 1]])

      cube([collector_width+2, offset+1, collector_height+1]);
  }
  translate([0,offset/2-depth/2, 0]) nodge();
  // add a bean to strengthen thin wall
  translate([0, collector_depth/2, collector_height-1.5]) cube([collector_width, 2, 3], center=true);
}

//****************************************
//Main
//secondary parameters
$fn = 32;
guidlinew = min(2,drill_diameter/2);
dtop = (guide_diameter + drill_diameter)/2;
channel_height = min(guide_height/2, 10+plate_thick);

//The thing
difference()
{
  union()
  {
    color("red") cylinder(d = guide_diameter, h = guide_height);
    plate(plate_width,plate_thick);
    translate([0, -collector_depth/2-plate_width/2, 0]) collector();
  }  
  
  //drillhole
  cylinder(d = drill_diameter , h = guide_height*3, center = true);

  //edge in top drillguide to make it easier to insert drill
  translate([0,0,guide_height + dtop/5])
    sphere(d= dtop);

  //sawdust-channel
  translate([-drill_diameter/4,-1-guide_diameter/2,-0.1]) 
    cube([drill_diameter/2, guide_diameter/2, channel_height]); 
}
