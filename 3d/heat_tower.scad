// Customizeable heat tower. 
// Inspired by Thingieverse #2213410
// String functiosn from Thingiverse #1237203

// Comma seperated list of step labels, from top to bottom
label_list = "180,185,190,195,200,205";

text_depth = 0.4;

text_size = 3;

text_font = "Helvetica:black";

// Roudness resolution
$fn=32;

// Rotation angle to have the best view in Thingiverse.
rotation = -90;

/* [Hidden] */

// Step radius
r=10;

// Step height
h=5;

d = 2*r;

eps1 = 0.01;
eps2 = 2 * eps1;

function strcat(v, sep="", str="", i=0, j=0) =
	i == len(v) ? str :
	j == len(v[i])-1 ? strcat(v, sep,
		str(str, v[i][j], i == len(v)-1 ? "" : sep),   i+1, 0) :
	strcat(v, sep, str(str, v[i][j]), i, j+1);
  
function split(str, sep=",", i=0, word="", v=[]) =
	i == len(str) ? concat(v, word) :
	str[i] == sep ? split(str, sep, i+1, "", concat(v, word)) :
	split(str, sep, i+1, str(word, str[i]), v);
  
module uncut_step() {
  h1 = h + eps1;
  cylinder(r=r, h=h1);
  translate([0, -r, 0]) cube([r, 2*r, h1]);
  translate([-r, 0, 0]) cube([r, r, h1]);
}

// Diagonal cut
module step_cut() {
translate([0, 0.5*r-eps1, -eps1])
rotate([45, 0, 0]) 
translate([-2*r, 0, -1*r]) 
cube([4*r, 1*r, 1*r]);
}


module step_text(msg) {
 translate([r-eps1, -r*0.15, h/2]) 
 rotate([0, 90, 0]) 
 rotate([0, 0, 90]) 
 linear_extrude(height = text_depth+eps1)
   text(msg, halign="center",valign="center", size=text_size+eps1, font=text_font); 
}

module step_mark() {
  translate([r-eps1, -r, 0])
  cube([text_depth+eps1, text_size, text_size*0.15]);  
}

module step(msg) {
  difference() {
    uncut_step();
    step_cut();
    rotate([0, 0, 45]) step_cut();
  }
  step_text(msg);
  step_mark();
}

module main() {
  labels = split(label_list);
  n = len(labels);
  for (i = [1 : n]) {
    translate([0, 0, (i-1)*h]) step(labels[n-i]);
  }
}

rotate([0, 0, rotation])   
main();


