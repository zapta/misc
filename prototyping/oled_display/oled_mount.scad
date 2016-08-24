// Mounting tab for 1.3" OLED displays. Use the side of a hot
// solder iron to 'rivet' the tabs on the display and main PCB 
// side.

/* [Global] */

// Width of the oval tab at the display side.
w3=1.9;
// Width of the support btween the display and main PCB.
w2=3;
// Diameter of the round tab at the main PCB side. Default
// is for a 3mm home. Hole center is offest by (w1-w3)/2 mm 
// toward the pin row of the display.
w1=2.7;

// Length of the oval tab at the display side.
l3=4;
// Length of space between the display and manin PCB.
l2=6;
// Length of the round tab at the main PCB side (round).
l1=w1;  

// Height of the oval tab at the display side.
h3=2.8;
// Height of space between the display and manin PCB.
h2=2.1;
// Height of the round tab at the main PCB side.
h1=3.5;

/* [Hidden] */

// Roundness
$fn=32;

total_height = h1 + h2 + h3;

// For maintaining manifold.
eps = 0.001;

module oval(x, y, z, w, l, h) {
  translate([x, y, z]) hull() {
    translate([-(l-w)/2, 0, 0]) cylinder(h=h, d=w);
    translate([(l-w)/2, 0, 0]) cylinder(h=h, d=w);
  }
}

module main() {
  translate([0, 0, w1/2]) rotate([90, 0, 0]) union() {
    oval(0, 0, 0, w1, l1, h1+eps);
    oval(0, (w2-w1)/2, h1, w2, l2, h2+eps);
    oval(0, (w3-w1)/2, h1+h2, w3, l3, h3);
  }
}

main();
