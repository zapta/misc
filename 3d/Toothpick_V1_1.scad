/*      
        Customizable Funny toothpick dispenser
        by "shusy" https://www.thingiverse.com/thing:3283381
        December 2018
        Version 1.1
        - Added variable toothpick length
*/


$fn=72*1; // smothing
mant=3*1; // width of body weigthlifter 
e=0.02*1; // precision
vol=10*1; // width of storage

// toothpick length
Pick_len= 65; 

// extrabase
extrabase = 7;

holder(extrabase);
translate([0,25,0])cover();
translate([0,60,0])top();



module top(){
difference(){
    union(){
        cube([Pick_len+7,1.5,2*vol+mant+3.5],center=true);    
        translate([17,2.75,vol+mant/2-0.2])rotate([90,0,0])cylinder(d=1,h=2.5);
        translate([17,2.75,-(vol+mant/2-0.2)])rotate([90,0,0])cylinder(d=1,h=2.5);
        translate([-17,2.75,vol+mant/2-0.2])rotate([90,0,0])cylinder(d=1,h=2.5);
        translate([-17,2.75,-(vol+mant/2-0.2)])rotate([90,0,0])cylinder(d=1,h=2.5);
        translate([0,1.5,0])
        difference(){
            cube([Pick_len+3.5-e,2.5,2*vol+mant-0.4],center=true);    
            cube([Pick_len,2.5+e,2*vol+mant-3.4],center=true);
        }
    }
    cube([Pick_len+3.7,8,mant+0.6],center=true);    
    }
}   



module cover(){
    translate([0,23 ,0])difference(){
        cube([Pick_len+7,9,2*vol+mant+3.5],center=true);
        cube([Pick_len+5-1.5,9+e,2*vol+mant],center=true);
    }

    translate([0,18,0])insert();
    difference(){
        cube([Pick_len+7,41.5,2*vol+mant+3.5],center=true);
        cube([Pick_len+5,41.5+e,2*vol+mant+0.4],center=true);
    }

    translate([0,-18.5,(vol+mant/2-0.5)])scale([1,0.7,1])cylinder(d=4.4,h=1.5);
    translate([0,-18.5,-(vol+mant/2+0.5)])scale([1,0.7,1])cylinder(d=4.4,h=1.5);
}

module insert(){
difference(){
    cube([Pick_len+5,9,2*vol+mant+1],center=true);
    translate([0,-2.5-e,0])union(){
        translate([0,-1,0])cube([Pick_len+3.4,2,mant+0.6],center=true);
        hull(){
            cube([Pick_len+3.6,0.1,mant+0.2],center=true);
            translate([0,7,0])cube([Pick_len+3.6,0.1,2*vol+mant],center=true);

        }
}
}
}

module holder(exbase=0){
translate([0,-24,0])minkowski(){
    cube([Pick_len-1.5,12,mant/2],center=true);
    cylinder(r=2,h=mant/2,center=true);
}

    if(exbase)translate([0,-59.5-exbase,0])cube([Pick_len+4.4,exbase,2*vol+mant-0.4],center=true);
    translate([0,-46.0,0])
difference(){
   cube([Pick_len +4.4,34,2*vol+mant-0.4],center=true);
   union(){
       translate([0,-3-e,0])cube([Pick_len+2,24,2*vol-2],center=true);
       translate([0,8.9-e,0])hull(){
            cube([Pick_len+2,0.1,2*vol-2],center=true);
            translate([0,7,0])cube([Pick_len-6,0.1,0.1],center=true);
        }
        translate([0,13,-(vol+mant/2-0.5)+e])paz();
        translate([0,13,(vol+mant/2-0.5)-e])paz();
    }
}
    
translate([0,-7.5,0])
head();


union(){
difference(){
    cylinder(d=40,h=mant,center=true);
    union(){
        translate([0,3,0])cylinder(d=33,h=mant+2*e,center=true);
        translate([0,15,0])cube([56,30,mant+2*e],center=true);
    }
}
mirror([1, 0, 0])hand();
hand();
}
}

module head(){
    difference(){
    cylinder(d=15,h=mant,center=true);
    union(){
        translate([2,2,-mant/2-e])scale([1,1.4,1])cylinder(d=2,h=0.6, center=true);
        translate([-2,2,-mant/2-e])scale([1,1.4,1])cylinder(d=2,h=0.6,center=true);
        translate([2,2,mant/2+e])scale([1,1.4,1])cylinder(d=2,h=0.6, center=true);
        translate([-2,2,mant/2+e])scale([1,1.4,1])cylinder(d=2,h=0.6,center=true);

    }
}
}
module hand(){
translate([-18,2,0])
difference(){
    cylinder(d=6,h=mant,center=true);
    union(){
        translate([0,2.5,-e])cube([7,4,mant+3*e],center=true);
        translate([0,.3,0])rotate([0,90,0])rotate([0,0,45])cube([1.5,1.5,6+2*e],center=true);
    rotate([0,90,0])translate([0,1.4,-e])cube([2.2,2.2,6],center=true);
    }
}
}

module paz(){
    hull(){
    cylinder(d=5,h=1,center=true);
    translate([0,-26,0])cylinder(d=5,h=1,center=true);
}
}
