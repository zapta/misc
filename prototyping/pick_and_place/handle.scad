$fn=72;

// DXF was exported from inkspace using the Better DXF extension
// http://www.bobcookdev.com/inkscape/inkscape-dxf.html. The standard
// export did not work well.

rotate_extrude(convexity = 10)

//rotate([0, 0, 0])  

translate([0, 197, 0]) 

import(file = "handle_profile.dxf");

//cylinder(d=4, h=125);
