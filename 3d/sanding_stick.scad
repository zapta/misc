/*
 * Parametric Sanding Stick - https://www.thingiverse.com/thing:2404850
 * by Dennis Hofmann - https://www.thingiverse.com/sasdensas/about
 * created 2017-06-28
 * version v1.1
 *
 * Changelog
 * --------------
 * v1.1:
 *  - added color
 *  - updated comment description for screw settings
 * --------------
 * 
 * This work is licensed under the Creative Commons - Attribution - Non-Commercial license.
 * https://creativecommons.org/licenses/by-nc/3.0/
 */

 // Parameter Section //
//-------------------//

// preview[view:south, tilt:top diagonal]

/* [Sanding Stick Settings] */

// Choose, which parts you need.
part_option = "all_parts"; //[all_parts,one_screw,two_screws,bottom_part,top_part]

// The width of the Sanding Stick / Sanding Paper Strip
stick_width_in_millimeter = 20.0; //[9:60]

// The height of the Stick will not be higher than the Base height. This value influences the width of wedge ends.
base_height_in_millimeter = 12.0; //[10:40]

// This is the length of the Base without the length of the ends
base_length_in_millimeter = 50.0; //[37:200]

// Choose, which option for the first end you wish.
end_1_option = "wedge"; //[none,round,wedge]

// Choose between the base_height and half_base_height of the first end. This value also influences the width of the ends. half_base_height is the same height, as the main part of the Sanding Stick.
end_1_height = "base_height"; //[base_height,half_base_height]

// Set the wedge angle of the first end
end_1_wedge_angle = 45/3; // [5:75]

// If you want a sharp end of the wedge, set 0. If you want a round end, set > 0. 
end_1_wedge_round_tip_diameter_in_millimeter = 2.0;

// Choose, which option for the second end you wish.
end_2_option = "round"; //[none,round,wedge]

// Choose between the base_height and half_base_height of the second end. This value also influences the width of the ends. half_base_height is the same height, as the main part of the Sanding Stick.
end_2_height = "base_height"; //[base_height,half_base_height]

// Set the wedge angle of the second end.
end_2_wedge_angle = 10.0; //[3:135]

// If you want a sharp end of the wedge, set 0. If you want a round end, set > 0.
end_2_wedge_round_tip_diameter_in_millimeter = 3.0;


/* [Screw Settings (Advanced!)] */

// Thread diameter of the screw
screw_thread_dia_in_millimeter = 6.0;

// Max head diameter of the screw. If the stick width is smaller, the stick width takes place as the head diameter. If you set a higher value, you should also increase the Screw Head Space value for the top part.
screw_head_dia_in_millimeter = 12.0;

// Thread hole diameter of the sanding stick bottom part. You should use Screw Thread Dia and add about 0.5-0.8 mm for tolerance. Otherwise the screw won't fit the threaded hole of the bottom part.
screw_thread_hole_dia_in_millimeter = 6.2;

// The hole diameter of the sanding stick top part. You should use Screw Thread Dia and add about 0.5-0.8 mm for tolerance. Otherwise the screw won't fit through the top part.
screw_hole_dia_in_millimeter = 6.4;

// The space of the sanding stick top part. This space is needed for the screw. This value should be higher than the Screw Head Dia value.
screw_head_space_in_millimeter =  15.0;

// Number of teeth of the screw head.
screw_head_teeth = 8; //[2:32]

// Max thread height for screw and sanding stick bottom part. Higher value results in a stronger join between the bottom and top part of the sanding stick, but also takes longer to screw it in.
max_thread_height_in_millimeter = 6;

/* [Hidden] */
stick_width = stick_width_in_millimeter;
base_length = base_length_in_millimeter;
base_height = base_height_in_millimeter;
screw_thread_dia = screw_thread_dia_in_millimeter;
screw_head_dia = screw_head_dia_in_millimeter;
screw_thread_hole_dia = screw_thread_hole_dia_in_millimeter;
screw_hole_dia = screw_hole_dia_in_millimeter;
screw_head_space = screw_head_space_in_millimeter;
max_thread_height = max_thread_height_in_millimeter;

$fn=100;

 // Program Section //
//-----------------//

if(part_option == "all_parts" || part_option == "bottom_part") {
    union() {
         base_bottom(base_length, base_height / 2, stick_width);
        
        if(end_1_option == "round") {
             round_end_1(base_height, stick_width, end_1_height);
        }
        if(end_1_option == "wedge") {
             wedge_end_1(base_height, end_1_height, stick_width, end_1_wedge_angle, end_1_wedge_round_tip_diameter_in_millimeter);
        }
                
        translate([base_length, 0, 0]) {
            if(end_2_option == "round") {
                 round_end_2(base_height, stick_width, end_2_height);
            }
            if(end_2_option == "wedge") {
                 wedge_end_2(base_height, end_2_height, stick_width, end_2_wedge_angle, end_2_wedge_round_tip_diameter_in_millimeter);
            }
        }
    }
}

if(part_option == "all_parts" || part_option == "top_part") {
    //translate([-1, -20, 6]) 
    translate([0, stick_width + 4.0, 0]) {
        base_top(base_length, base_height / 2 - 0.5, stick_width);
    }
}

if(part_option == "all_parts" || part_option == "one_screw" || part_option == "two_screws") {
    translate([screw_head_dia / 2, stick_width + screw_head_dia + 3.0, 0]) {
         screw(screw_thread_dia, base_height / 2 - 1.5, base_height / 4 - 0.3, screw_head_dia, base_height / 4);
    }
}

if(part_option == "all_parts" || part_option == "two_screws") {
    translate([screw_head_dia * 1.5 + 4, stick_width + screw_head_dia + 3.0, 0]) {
       screw(screw_thread_dia, base_height / 2 - 1.5, base_height / 4 - 0.3, screw_head_dia, base_height / 4);
    }
}

 // Module Section //
//----------------//

module base_bottom(length, height, width) {
    difference() {
        rotate([90, 0, 0]) {
            linear_extrude(height = width) {
                square([length, height]);
            }
        }
        
        // Hole 1    
        if(height < max_thread_height + 1.5) {
            translate([4 + screw_head_space / 2, - width / 2, 1.5]) {
                screw_thread(screw_thread_hole_dia, 1.25, 45, height - 1, PI / 4, 1);
            }
        } else {
            translate([4 + screw_head_space / 2, - width / 2, height - max_thread_height]) {
                screw_thread(screw_thread_hole_dia, 1.25, 45, max_thread_height + 0.3, PI / 4, 1);
            }
        }
        
        // Hole 2   
        if(height < max_thread_height + 1.5) {
            translate([length - 4 - screw_head_space / 2, - width / 2, 1.5]) {
                screw_thread(screw_thread_hole_dia, 1.25, 45, height - 1, PI / 3, 1);
            }
        } else {
            translate([length - 4 - screw_head_space / 2, - width / 2, height - max_thread_height]) {
                screw_thread(screw_thread_hole_dia, 1.25, 45, max_thread_height + 0.3, PI / 3, 1);
            }
        }
        
        // Chamfer
        translate([4 + screw_head_space / 2, - width / 2, height - 0.6]) {
            cylinder(d1 = screw_thread_hole_dia, d2 = screw_hole_dia * 1.2, h = 0.7);
        }
        translate([length - 4 - screw_head_space / 2, - width / 2, height - 0.6]) {
            cylinder(d1 = screw_thread_hole_dia, d2 = screw_hole_dia * 1.2, h = 0.7);
        }
    }
}

module base_top(length, height, width) {
    x = 3;
    difference() {
        translate([-x/2, 0, 0])
        #rotate([90, 0, 0]) {
            linear_extrude(height = width) {
                offset(r= + height * 0.3, $fn = 32) {
                    offset(delta =  - height * 0.3) {
                        #square([length+x, height]);
                    }
                }
            }
        }
        // Screw Space 1
        translate([4, -width - 0.5, height / 2 + 0.1]) {
            cube([screw_head_space, width + 1.0, height / 2]);
        }
        // Screw Hole 1
        translate([4 + screw_head_space / 2, - width / 2, - 0.1]) {
            cylinder(d = screw_hole_dia, h = height / 2 + 0.3);
        }
        
        // Screw Space 1
        translate([length - 4 - screw_head_space, - width - 0.5, height / 2 + 0.1]) {
            cube([screw_head_space, width + 1.0, height / 2]);
        }
        // Screw Hole 2
        translate([length - 4 - screw_head_space / 2, - width / 2, - 0.1]) {
            cylinder(d = screw_hole_dia, h = height / 2 + 0.3);
        }
    }
}

module screw(thread_dia, thread_height, threadless_height, head_dia, head_height) {
    union() {
        if(head_dia > stick_width) {
            gear(stick_width, head_height, screw_head_teeth);
        } else {
            gear(head_dia, head_height, screw_head_teeth);
        }
        translate([0, 0, head_height]) {
            cylinder(d = thread_dia, h = threadless_height, $fn = 16);
        }
        translate([0, 0, head_height + threadless_height - 0.1]) {
            if(thread_height < max_thread_height) {
                screw_thread(thread_dia, 1.25, 45, thread_height, PI / 4, 1);
            } else {
                screw_thread(thread_dia, 1.25, 45, 3.5, PI / 3, 1);
            }
        }
    }
}

module gear(dia, height, teeth) {
    union() {
        translate([0, 0, height / 2]) {
            for(tooth = [0 : teeth / 2]) {
                rotate([0, 0, 360 / teeth * tooth]) {
                    cube([dia, dia / screw_head_teeth, height], center = true);
                }
            }
        }
        cylinder(d = dia - 2.0, h = height, $fn=16);
    }
}

module round_end_1(dia, width, height_option) {
    dia = height_option == "base_height" ? dia : dia / 2;
    transition_width = height_option == "base_height" ? -dia / 2 + dia / 4 + 0.0001 : 0;
    union() {
        translate([transition_width, 0, dia / 2]) {
            rotate([90, 0, 0]) {
                difference() {
                    cylinder(d = dia, h = width, $fn = 128);
                    translate([0, -dia / 2, -0.1]) {
                        cube([dia, dia + 0.2, width + 0.2]);
                    }
                }
            }
        }
        if(height_option == "base_height") {
            base_end_transition(dia, width);
        }
    }
}

module round_end_2(dia, width, height_option) {
    translate([0, -width, 0]) {
        rotate([0, 0, 180]) {
            round_end_1(dia, width, height_option);
        }
    }
}

module wedge_end_1(max_height, height_option, width, angle, tip_dia) {
    tip_r = tip_dia / 2;
    height = height_option == "base_height" ? max_height : max_height / 2;
    bottom_width = height / tan(angle) - tip_r / tan(angle / 2);
    top_delta = sin(angle) * tip_r;
    top_height = height - (tan(angle) * (bottom_width + top_delta));
    transition_width = height_option == "base_height" ? height / 4 - 0.05 : 0;
    union() {
        translate([-bottom_width - transition_width, 0, 0]) {
            rotate([90, 0, 0]) {
                linear_extrude(height = width) {
                    polygon(points = [
                        [0, 0], 
                        [bottom_width, 0],
                        [bottom_width, height],
                        [0 - top_delta, top_height],
                        [0, tip_r]
                    ]);
                    translate([0, tip_r]) {
                        circle(d = tip_dia, $fn = 64);
                    }
                }
            }
        }
        if(height_option == "base_height") {
            base_end_transition(height, width);
        }
    }
}

module wedge_end_2(max_height, height_option, width, angle, tip_dia) {
    translate([0, -width, 0]) {
        rotate([0, 0, 180]) {
            wedge_end_1(max_height, height_option, width, angle, tip_dia);
        }
    }
}

module base_end_transition(dia, width) {
    translate([-dia / 2 + dia / 4 , 0, dia / 2]) {
        rotate([90, 0, 0]) {
            union() {
                translate([0, dia / 2 - dia / 8, 0]) {
                    difference() {
                        cylinder(d = dia / 4, width, $fn = 32);
                        translate([-dia / 4, -dia / 4, -0.1]) {
                            cube([dia / 4, dia / 2, width + 0.2]);
                        }
                    }
                    translate([-0.1, -dia + dia / 8, 0]) {
                        cube([dia / 8 + 0.1, dia - dia / 8, width]);
                    }
                }
                translate([dia / 4, dia/2 - dia / 8, 0]) {
                    difference() {
                        translate([-dia / 8, -dia + dia / 8, 0]) {
                            cube([dia / 8, dia / 2 + dia / 8, width]);
                        }
                        translate([0, -dia / 4, -0.1]) {
                            cylinder(d = dia / 4, width + 0.2, $fn = 32);
                        }
                    }
                }
            }
        }
    }
}


////////////////////////////////////////////////////////////////////////
/*
 *    polyScrewThread_r1.scad    by aubenc @ Thingiverse
 *
 * This script contains the library modules that can be used to generate
 * threaded rods, screws and nuts.
 *
 * http://www.thingiverse.com/thing:8796
 *
 * CC Public Domain
 * 
 * Changes by Dennis Hofmann:
 * - removed unused modules
 * - fixed deprecated parts
 */

module screw_thread(od,st,lf0,lt,rs,cs)
{
    or=od/2;
    ir=or-st/2*cos(lf0)/sin(lf0);
    pf=2*PI*or;
    sn=floor(pf/rs);
    lfxy=360/sn;
    ttn=round(lt/st+1);
    zt=st/sn;

    intersection()
    {
        if (cs >= -1)
        {
           thread_shape(cs,lt,or,ir,sn,st);
        }

        full_thread(ttn,st,sn,zt,lfxy,or,ir);
    }
}

module thread_shape(cs,lt,or,ir,sn,st)
{
    if ( cs == 0 )
    {
        cylinder(h=lt, r=or, $fn=sn, center=false);
    }
    else
    {
        union()
        {
            translate([0,0,st/2])
              cylinder(h=lt-st+0.005, r=or, $fn=sn, center=false);

            if ( cs == -1 || cs == 2 )
            {
                cylinder(h=st/2, r1=ir, r2=or, $fn=sn, center=false);
            }
            else
            {
                cylinder(h=st/2, r=or, $fn=sn, center=false);
            }

            translate([0,0,lt-st/2])
            if ( cs == 1 || cs == 2 )
            {
                  cylinder(h=st/2, r1=or, r2=ir, $fn=sn, center=false);
            }
            else
            {
                cylinder(h=st/2, r=or, $fn=sn, center=false);
            }
        }
    }
}

module full_thread(ttn,st,sn,zt,lfxy,or,ir)
{
  if(ir >= 0.2)
  {
    for(i=[0:ttn-1])
    {
        for(j=[0:sn-1]) {
			pt = [	    [0,                  0,                  i*st-st            ],
                        [ir*cos(j*lfxy),     ir*sin(j*lfxy),     i*st+j*zt-st       ],
                        [ir*cos((j+1)*lfxy), ir*sin((j+1)*lfxy), i*st+(j+1)*zt-st   ],
						[0,                  0,                  i*st               ],
                        [or*cos(j*lfxy),     or*sin(j*lfxy),     i*st+j*zt-st/2     ],
                        [or*cos((j+1)*lfxy), or*sin((j+1)*lfxy), i*st+(j+1)*zt-st/2 ],
                        [ir*cos(j*lfxy),     ir*sin(j*lfxy),     i*st+j*zt          ],
                        [ir*cos((j+1)*lfxy), ir*sin((j+1)*lfxy), i*st+(j+1)*zt      ],
                        [0,                  0,                  i*st+st            ]	];
        
            polyhedron(points=pt,
              		  faces=[	[1,0,3],[1,3,6],[6,3,8],[1,6,4],
											[0,1,2],[1,4,2],[2,4,5],[5,4,6],[5,6,7],[7,6,8],
											[7,8,3],[0,2,3],[3,2,7],[7,2,5]	]);
        }
    }
  }
  else
  {
    echo("Step Degrees too agresive, the thread will not be made!!");
    echo("Try to increase de value for the degrees and/or...");
    echo(" decrease the pitch value and/or...");
    echo(" increase the outer diameter value.");
  }
}
