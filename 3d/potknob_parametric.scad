/*

Parametric Potentiometer Knob Generator
version 1.1
2012 Steve Cooley
http://sc-fa.com
http://beatseqr.com
http://hapticsynapses.com

parametric potentiometer knob generator by steve cooley is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. Based on a work at sc-fa.com. Permissions beyond the scope of this license may be available at http://sc-fa.com/blog/contact.

view terms of the license here:
http://creativecommons.org/licenses/by-nc-sa/3.0/


version history
---------------
1.1 2012-04-12 fixed the arrow indicator code to be more robust and easier to adjust parameters for.
1.0 2012-03-?? initial release.


*/


//
//
// Physical attributes, basic
//
//

knob_radius_top = 10;
knob_radius_bottom = 10;
knob_height = 16;
knob_smoothness = 20;

shaft_radius = 3.25;
shaft_height = 13;
shaft_smoothness = 20;

shaft_is_flatted = true;
flat_size_adjustment = -0.0;
// you won't need to mess with this. less than 5 makes it disappear. you can, however,
// set the adjustment to be a negative decimal if you need a flat but not as big as the default. 
// go positive if you need a bigger flat
flat_size = 5 + flat_size_adjustment;

// some potentiometers need to have their knobs affixed with a set screw.
set_screw = true;
set_screw_radius = 1.5;
set_screw_depth = 9;
set_screw_height = 4;
quality_of_set_screw = 20;

//
// 
// Decorations
//
//

//
// top edge smoothing
// thanks to http://www.iheartrobotics.com/ for the articles!
//

smoothing = true;
smoothing_radius = 3;				// tweak on this one, how much smoothing to apply
smooth = 20;						// tweak on this one, Number of facets of rounding cylinder

ct = -0.1; 							// circle translate? not sure.
circle_radius = knob_radius_top;  	// just match the top edge radius
circle_height = 1; 					// actually.. I don't know what this does.
pad = 0.2;							// Padding to maintain manifold


//
// directional indicators
//

// this is a corner edge of a cube sticking out of the cylinder at the bottom
// you can use it instead of the arrow shaped cutout in the top if you like. Or both.

pointy_external_indicator = false;
pointy_external_indicator_height = 11;
pointy_external_indicator_pokey_outey_ness = -0.0; // 
pokey_outey_value = pointy_external_indicator_pokey_outey_ness - 1 - pad;
pokey_outey = [pokey_outey_value, pokey_outey_value,0];

// there's an arrow shaped hole you can have. There aren't a lot of controls for this.
// please feel free to improve on this script here.

arrow_indicator = true;
arrow_indicator_scale = 1.3;
arrow_indicator_translate = [0,1,16];
arrow_scale_head = 2;
arrow_scale_shaft = 1.5;

//
// indentations
//

// for spherical indentations, set the quantity, quality, size, and adjust the placement
indentations_sphere = false;
sphere_number_of_indentations = 12;
sphere_quality_of_indentations = 4;
size_of_sphere_indentations = 4;
// the first number in this set moves the spheres in or out. smaller is closer to the middle
// the second number in this set moves the spheres left or right
// the third number in this set moves the speheres up or down
translation_of_sphere_indentations = [10,0,15];
// in case you are using an odd number of indentations, you way want to adjust the starting angle
// so that they align to the front or set screw locations.
sphere_starting_rotation = 90;

// for cylinder indentations, set quantity, quality, radius, height, and placement
indentations_cylinder = true;
cylinder_number_of_indentations = 10;
cylinder_quality_of_indentations = 50;
radius_of_cylinder_indentations_top = 3;
radius_of_cylinder_indentations_bottom = 5;
height_of_cylinder_indentations = 12;
translation_of_cylinder_indentations = [0,8,-8];
cylinder_starting_rotation = -33.3;

// these are some setup variables... you probably won't need to mess with them.
negative_knob_radius = knob_radius_bottom*-1;


// this is the main module. It calls the submodules.
make_the_knob();

module make_the_knob()
{
	difference()
		{
		difference()
			{
		
			difference() 
				{
				difference() 
					{
					
					union()
						{
						
						difference()
							{
							// main cylinder
							cylinder(r1=knob_radius_bottom,r2=knob_radius_top,h=knob_height, $fn=knob_smoothness);
							
							smoothing();				
		
							}
				
						external_direction_indicator();	
						}
					
					shaft_hole();
					}
					
				set_screw_hole();
				}
			
			arrow_indicator();
			indentations();
		}
	}

}

module smoothing() {

// smoothing the top
				if(smoothing == true)
					{		
						translate([0,0,knob_height])
						rotate([180,0,0])
						difference() {
							rotate_extrude(convexity=10,  $fn = smooth)
							translate([circle_radius-ct-smoothing_radius+pad,ct-pad,0])
							square(smoothing_radius+pad,smoothing_radius+pad);
	
							rotate_extrude(convexity=10,  $fn = smooth)
							translate([circle_radius-ct-smoothing_radius,ct+smoothing_radius,0])
							circle(r=smoothing_radius,$fn=smooth);
							}	
					}
}

module external_direction_indicator() {

				if(pointy_external_indicator == true)
						{
						
						
						// outer pointy indicator
						rotate([0,0,45])
						translate(pokey_outey)
						// cube size of 8 minimum to point out
						cube(size=[knob_radius_bottom,knob_radius_bottom,pointy_external_indicator_height],center=false);
						}

}

module shaft_hole() {
				// shaft hole
				difference()
					{
					
					// round shaft hole
					translate([ 0, 0, -1 ]) 
					cylinder(r=shaft_radius,h=shaft_height, $fn=shaft_smoothness);
					
					if(shaft_is_flatted == true)
						{
						// D shaft shape for shaft cutout
						rotate( [0,0,90]) 
						translate([-7.5,-5,0]) 
						cube(size=[flat_size,10,13],center=false);
						}
					}
}


module set_screw_hole() {

			if(set_screw == true)
				{
				// set screw hole
				rotate ([90,0,0])
				translate([ 0, set_screw_height, 1 ])
				cylinder(r=set_screw_radius,h=set_screw_depth, $fn=quality_of_set_screw);
				}
}

module arrow_indicator() {
		if(arrow_indicator == true)
			{
			translate(arrow_indicator_translate)
			// begin arrow top cutout
			// translate([(knob_radius/2),knob_height,knob_height])
			rotate([90,0,45])
			scale([arrow_indicator_scale*.3,arrow_indicator_scale*.3,arrow_indicator_scale*.3])
			union()
				{			  
				rotate([90,45,0])
				scale([arrow_scale_head,arrow_scale_head,1])
				cylinder(r=8, h=10, $fn=3, center=true);
				rotate([90,45,0])
				translate([-10,0,0])
				scale([arrow_scale_shaft,arrow_scale_shaft,1])
				cube(size=[15,10,10],center=true);
				}
			}
}

module indentations() {

if(indentations_sphere == true)
			{
			for (z = [0:sphere_number_of_indentations]) 
				{
				rotate([0,0,sphere_starting_rotation+((360/sphere_number_of_indentations)*z)])
				translate(translation_of_sphere_indentations)
				sphere(size_of_sphere_indentations, $fn=sphere_quality_of_indentations); 
				}
			}
if(indentations_cylinder == true)
			{
			for (z = [0:cylinder_number_of_indentations]) 
				{
				rotate([0,0,cylinder_starting_rotation+((360/cylinder_number_of_indentations)*z)])
				
				translate([negative_knob_radius,0,knob_height])
				translate(translation_of_cylinder_indentations)
				cylinder(r1=radius_of_cylinder_indentations_bottom, r2=radius_of_cylinder_indentations_top, h=height_of_cylinder_indentations, center=true, $fn=cylinder_quality_of_indentations); 
				}
			}
		}
