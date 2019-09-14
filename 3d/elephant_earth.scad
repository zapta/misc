
difference() {
    scale(2) import("elephant.stl", convexity=3);
    
    
    translate([14, 18, 23.1])
    #rotate([0, 0, 90])
    linear_extrude(height = 2)
     text("EARTH", halign="center",valign="center", spacing=1.1, size=10, font="Helvetica:black");
}

