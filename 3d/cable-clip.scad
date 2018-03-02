part = "flap"; // [rod,flap,demo]

thickness = 1.5; // [0.2:0.1:10]
height = 10;
cable_diameter = 5.5; // [2:0.5:100]
opening_angle = 110; // [0:179]
opening_rounding_radius = 2.2; // [0:0.2:50]
rod_diameter = 7.5; // [2:0.5:100]
flap_length = 16; // [0:100]
screw_diameter = 4; // [0:0.5:20]
// Position of the screw hole from cable center
screw_position = 11.6; // [0:100]
// Hint: set this to 0 to get a faster preview
chamfer = 0.25; // [0:0.05:1]

/* [Hidden] */

$fn=32;

module ring(dia,thickness,angle)
{
    difference() {
        circle(d=dia+2*thickness);
        circle(d=dia);
        l=dia/2+thickness+1;
        if (angle > 179) {
            polygon([[0,0],[0,l],[-l,l],[-l,0],[-l,-l],[l,-l],[l,l*tan(angle-90)]]);
        } else {
            polygon([[0,0],[0,l],[-l,l],[-l,0],[-l,-l*tan(angle-90)]]);
        }
    }
}

module flap_clip_section()
{
    ring(cable_diameter,thickness,opening_angle);

    pos = [-((cable_diameter/2+opening_rounding_radius)*sin(opening_angle)-.001),
        (cable_diameter/2+opening_rounding_radius)*cos(opening_angle)-.001];
    translate(pos)
        rotate(90)
            ring(2*(opening_rounding_radius-thickness),thickness,opening_angle+90);

    translate([-flap_length,cable_diameter/2])
        square([flap_length,thickness]);
}

module rod_clip_section()
{
    pos = [-((cable_diameter/2+thickness+rod_diameter/2)*sin(opening_angle)-.001),
        (cable_diameter/2+thickness+rod_diameter/2)*cos(opening_angle)-.001];
    
    ring(cable_diameter,thickness,opening_angle);
    translate([0,cable_diameter/2+opening_rounding_radius])
        rotate(180)
            ring(2*(opening_rounding_radius-thickness),thickness,opening_angle+90);
    translate(pos)
        rotate(180)
            ring(rod_diameter,thickness,opening_angle);
    translate([pos.x,pos.y-rod_diameter/2-opening_rounding_radius])
        ring(2*(opening_rounding_radius-thickness),thickness,opening_angle+90);
}

module chamfer_chisel()
{
    cylinder(r1=chamfer,r2=0,h=chamfer,$fn=8);
    mirror([0,0,1])
        cylinder(r1=chamfer,r2=0,h=chamfer,$fn=8);
}

module part(part)
{
    difference() {
        if (chamfer > 0) {
            minkowski() {
                translate([0,0,chamfer]) {
                    linear_extrude(height-2*chamfer) {
                        offset(-chamfer) {
                            if (part == "flap")
                                flap_clip_section();
                            else
                                rod_clip_section();
                        }
                    }
                }
                chamfer_chisel();            
            }
        } else {
            // Avoid minkowski() for speedup
            linear_extrude(height) {
                if (part == "flap")
                    flap_clip_section();
                else
                    rod_clip_section();
            }
        }

        if (part == "flap") {
            translate([-screw_position,cable_diameter/2,height/2]) {
                rotate([-90]) {
                    union() {
                        translate([0,0,-.001])
                            cylinder(d1=screw_diameter+2*chamfer,d2=screw_diameter,h=chamfer);
                        translate([0,0,-1])
                            cylinder(d=screw_diameter,h=thickness+2);
                        translate([0,0,thickness-chamfer])
                            cylinder(d1=screw_diameter,d2=screw_diameter+2*chamfer,h=chamfer+.001);
                    }
                }
            }
        }
    }
}

module demo()
{
    dist = 5;
    color("steelblue")
        render()
            translate([0,cable_diameter/2+thickness+dist/2])
                part("flap");
    color("darkorange")
        render() 
            translate([0,-max(rod_diameter,cable_diameter)/2-thickness-dist/2,0])
                rotate(-opening_angle/4)
                    part("rod");
}

if (part == "demo") {
    demo();
} else if (part == "rod") {
    rotate(-opening_angle/4)
        part(part);
} else {
    part(part);
}
