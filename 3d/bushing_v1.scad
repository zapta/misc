 /*
 * Customizable Linear Bushing - https://www.thingiverse.com/thing:2202854
 * by Dennis Hofmann - https://www.thingiverse.com/mightynozzle/about
 * created 2017-03-25
 * updated 2018-02-15
 * version v1.8
 *
 * Changelog
 * --------------
 * v1.8:
 *      - groove option added
 * v1.7:
 *      - fixed inner diameter
 * v1.6:
 *      - added chamfer angle option
 * v1.5:
 *      - fixed graphic glitch
 * v1.4:
 *      - added chamfer option
 *
 * v1.1-1.3:
 *      - initial model with minor changes in description
 *
 * --------------
 * 
 * This work is licensed under the Creative Commons - Attribution - Non-Commercial license.
 * https://creativecommons.org/licenses/by-nc/3.0/
 */
 
 // Parameter Section //
//-------------------//

/* [Bushing Settings] */

// Equals dr in technical diagrams. Use the outer diameter of the rod + tolerance value of your printer. Do some test prints before print a whole set of bushings. Best way in my case is to choose the bushing where can push it in with some effort on the rod and slide it by hand without any tools. Then slide it back and forth along the rod, until the bushing has the expected behavior. I suggest you not to use any drill or heat. The sliding of the bushing generates enough heat from its friction against the rod. Standard values: 6.00 for LM6(L)UU, 8.00 (default 8.15) for LM8(L)UU, 10.00 for LM10(L)UU, 12.00 for LM12(L)UU, 16.00 for LM16UU, ...
inner_diameter_in_millimeter = 8 + 0.30; //0.15;

// Equals D in technical diagrams. Use the inner diameter of housing where the bushing sits + tolerance value of your printer. Depends on the filament you use and the total wall thickness of the bushings, the bushing shouldn't fit to tight in the housing. Standard values: 12.0 for LM6(L)UU, 15.0 (default) for LM8(L)UU, 19.0 for LM10(L)UU, 21.0 for LM12(L)UU, 28.0 for LM16UU, ...
outer_diameter_in_millimeter = 15.0; 

// Equals L in technical diagrams. Standard values: 19.0 for LM6UU, 24.0 for LM8UU, 29.0 for LM10UU, 30.0 for LM12UU, 35.0 for LM6LUU, 37.0 for LM16UU, 45.0 for LM8LUU, 55.0 for LM10LUU, 57.0 for LM12LUU, ...
bushing_length_in_millimeter = 24; //50; //24.0;

// Use a value to get straight primeters without any zigzag between the outer and inner perimeter. I use the value of 0.48 for 0.4 nozzle. This is the auto extrusion width of 0.48 of simplify3d. More information about this in the description of this design on thingiverse.
extrusion_width_in_millimeter = 0.48; 

// Use even numbers. E.g. 4 for LM8(L)UU. Don't forget to set the perimeter number in your Slicer! 
number_of_perimeters = 4; //[2:2:10]

// Choose a number to provide a gap between the teeth in the bushing. E.g. 8 or 10 for LM8(L)UU. The tooth width depends on the extrusion_width_in_millimeter and the number_of_perimeters.
number_of_teeth = 10; //[3:20]

// Radius of the chamfer. Set a chamfer if you want to insert the rod easier. This also helps if your prints tends to create elephant foot in the first few layers. A value between 0.3 and 1.0 might be a good value. Set a value above 0 might destroy the preview of the bushing. But the resulting stl-File will be correct.
chamfer_radius_in_millimeter = 0.75; //0.0;

// Set the angle of the chamfer. 
chamfer_angle_in_degree = 55.0; // [30:75]

// Equals W in technical diagram. 1.1 for LM6/8(L)UU, 1.3 for LM10/12/13(L)UU, 1.6 for LM16/20(L)UU, 1.85 for LM25/30(L)UU, 2.1 for LM35/40(L)UU, 2.6 for LM50(L)UU, 3.15 for LM60(L)UU
groove_length_in_millimeter = 1;

// Equals D1 in technical diagram. 11.5 for LM6(L)UU, 14.3 for LM8(L)UU, 18.0 for LM10(L)UU, 20.0 for LM12(L)UU, 22.0 for LM13(L)UU, 27.0 for LM16(L)UU, 30.5 for LM20(L)UU, 38.0 for LM25(L)UU, 43.0 for LM30(L)UU, 49.0 for LM35(L)UU, 57.0 for LM40(L)UU, 76.5 for LM50(L)UU, 86.5 for LM60(L)UU
groove_diameter_in_millimeter = 14.3;

// Equals B in technical diagram. Outer distance between both grooves. 13.5 for LM6UU, 17.5 for LM8UU, 22.0 for LM10UU, 23.0 for LM12UU, 26.5 for LM16UU, 27.0 for LM6LUU, 35.0 for LM8UU, 44.0 for LM10LUU, 46.0 for LM12LUU, 53.0 for LM16LUU
groove_distance_in_millimeter = 13;

/* [Hidden] */
inner_dia = inner_diameter_in_millimeter;
outer_dia = outer_diameter_in_millimeter;
bushing_l = bushing_length_in_millimeter;
extrusion_w = extrusion_width_in_millimeter;
perimeters = number_of_perimeters;
teeth = number_of_teeth;
chamfer_r = chamfer_radius_in_millimeter;
chamfer_h = tan(chamfer_angle_in_degree) * chamfer_r;
groove_l = groove_length_in_millimeter;
groove_dia = groove_diameter_in_millimeter;
groove_d = groove_distance_in_millimeter;


$fn=100;

 // Program Section //
//-----------------//


main();

module main() {
color("HotPink") difference() {
    bushing();
    if(chamfer_r > 0) {
        chamfer_cut();
        translate([0, 0, bushing_l]) {
            rotate([180,0,0]) {
                chamfer_cut();
            }
        }
    }
    //groove_cut();
}
}


 // Module Section //
//----------------//

module bushing() {
    translate([0, 0, bushing_l / 2]) {
        difference() {
            union() {
                difference() {
                    for(tooth = [0 : teeth - 1])
                        rotate([0, 0, 360 / teeth * tooth]) {
                            translate([outer_dia / 4, 0, 0]) {
                                cube([outer_dia / 2, extrusion_w * perimeters, bushing_l + 1], center = true);
                            }
                        }
                        translate([0, 0, -bushing_l / 2-1]) {
                            ring(outer_dia * 2, outer_dia, bushing_l + 2);
                        }
                    }
                    translate([0, 0, -bushing_l / 2 - 1]) {
                        ring(outer_dia, outer_dia - extrusion_w * perimeters * 2, bushing_l + 2);
                    }
            }
            cylinder(d = inner_dia, h = bushing_l + 2, center = true);
            translate([0, 0, bushing_l / 2]) {
                cylinder(d = outer_dia + 1, h = 2, $f = 16);
            }
            translate([0, 0, -(bushing_l / 2 + 2)]) {
                cylinder(d = outer_dia + 1, h = 2, $f = 16);
            }
        }
    }
}

module ring(d1, d2, height) {
    difference() {
        cylinder(d = d1, h = height, center = false);
        cylinder(d = d2, h = height, center = false);
    }
}

module chamfer_cut() {
    union() {
        difference() {
            translate([0, 0, -1]) {
                cylinder(d = outer_dia + 1, h = chamfer_h + 1);
            }
            intersection() {
                cylinder(d = outer_dia, h = chamfer_h);
                cylinder(d1 = outer_dia - chamfer_r * 2, d2 = outer_dia, h = chamfer_h);
            }
        }
        translate([0, 0, -chamfer_h]) {
            intersection() {
                cylinder(d = inner_dia + chamfer_r * 4, h = chamfer_h * 2);
                cylinder(d1 = inner_dia + chamfer_r * 4, d2 = inner_dia, h = chamfer_h * 2);
            }
        }
        translate([0, 0, -10]) {
            cylinder(d = outer_dia + 1, h = 10);
        }
    }
}

module groove_cut() {
    translate([0, 0, bushing_l / 2 - groove_d / 2]) {
        ring(outer_dia + 1, groove_dia, groove_l);
    }
    translate([0, 0, bushing_l - ((bushing_l / 2) - (groove_d / 2) + groove_l)]) {
        ring(outer_dia + 1, groove_dia, groove_l);
    }
}
