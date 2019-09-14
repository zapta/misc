//What number do you want to be more likely to roll?
Number=6; //[1:6]

$fn=64;

//Create Dice with Light side on loaded number
module Dice(Side){
	module One(){
		sphere(r=2.75,$fn=20);
	}
	module Two(){
		translate([5.75,5.75,0]) One();
		translate([-5.75,-5.75,0]) One();
	}
	module Three(){
		One();
		Two();
	}
	module Four() {
		translate([5.75,5.75,0]) One();
		translate([-5.75,-5.75,0]) One();
		translate([-5.75,5.75,0]) One();
		translate([5.75,-5.75,0]) One();
	}
	module Five(){
		Four();
		One();
	}
	module Six(){
		Four();
		translate([5.75,0,0]) One();
		translate([-5.75,0,0]) One();
	}
	difference(){
		minkowski(){
			cube([20,20,20],center=true);
			sphere(r=5);
		}
		union(){
			rotate([0,180,0]) translate([0,0,14]) One();
			rotate([0,90,0]) translate([0,0,14]) Two();
			rotate([90,0,0]) translate([0,0,14]) Three();
			rotate([-90,0,0]) translate([0,0,14]) Four();
			translate([0,0,14]) Five();
			rotate([0,-90,0]) translate([0,0,14]) Six();
			rotate(Side) translate([0,0,5.5]) cube([15,15,8], center=true);
		}
	}
}
Loaded_One=[0,180,0];
Loaded_Two=[0,90,0];
Loaded_Three=[90,0,0];
Loaded_Four=[-90,0,0];
Loaded_Five=[0,0,0];
Loaded_Six=[0,-90,0];
if (Number==1){ Dice(Loaded_One);
} else if (Number==2) { Dice(Loaded_Two);
} else if (Number==3) {Dice(Loaded_Three);
}else if (Number ==4) {Dice(Loaded_Four);
} else if (Number==5) {Dice(Loaded_Five);
} else if (Number==6) {Dice(Loaded_Six); }

//Dice();