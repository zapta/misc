// Genereate a model to rectangular bed leveling test

eps=0.01 + 0;

// Chip size
s=10;
// Text size
t=6;
// Chip height
h=0.8;
// Total X width
xwidth = 140;
// Total Y width
ywidth = 110;

module chip(number) {
  difference() {
    // Square
    translate([-s/2, -s/2, 0]) cube([s, s, h]);
    // Substract text
    translate([0, 0, h/2]) linear_extrude(height = h/2+eps)
       #text(str(number), halign="center",valign="center", size=t, font="helvetica: style=bold");
  }
}

for (i =[0:8]) {
  dx = (1- (i % 3)) * (xwidth/2 - s/2);
  dy = (floor(i / 3) - 1) * (ywidth/2 - s/2);
  translate([dx, dy, 0])  chip(9-i);
}
