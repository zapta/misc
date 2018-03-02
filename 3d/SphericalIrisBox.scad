// spherical iris box

R=60;// outer radius
BaseH=30;// height from base to equator
T=1.6;// thickness of shells
tol=0.3;// tolerance for sliding
Rpin1=1.5;// radius of upper pin
Rpin=2.5;// radius of lower pin
phi=44.3;// angle of rotation axis
$fn=120;

W=3*T+2*tol;// total box thickness
psi=60.2;// angle of leaf motion
v=[-cos(phi),0,sin(phi)];
Rhole=Rpin1+2;

mirror([1,0,0]){
    rotate([0,0,51*Zto1($t)])outer();
    inner();
    for(i=[0:4])color([Zto1(i/5),Zto1((i/5+1/3)%1),Zto1((i/5+2/3)%1)])rotate([0,0,i*72])
        rotate(psi*Zto1($t),v)leaf();
}

module leaf()
render(convexity=4)
intersection(){
    difference(){
        sphere(r=R-T-tol);
        sphere(r=R-2*T-tol);
        translate([0,0,W*sqrt(2)/2])cylinder(r1=0,r2=R,h=R);
        translate([0,0,-R-BaseH])cube(2*R,center=true);
        rotate([0,0,90])translate([Rhole,0,-R])cube([R,R,2*R]);
        difference(){
            rotate([0,phi-90,0])translate([0,Rhole,0])rotate([0,0,-55])cube([3*Rhole,3*Rhole,R]);
            rotate([0,phi-90,0])translate([0,-Rhole*.5,0])scale([1,1.5,1])cylinder(r=Rhole,h=R,$fn=20);
        }
        rotate([0,phi-90,0])cylinder(r=Rpin1+tol,h=R,$fn=12);
        translate([0,0,2])rotate([0,-90,5]){
            cylinder(r=Rpin+tol,h=R,$fn=12);
            translate([-23,-Rpin-tol,0])cube([23,(Rpin+tol)*2,R]);
        }
        rotate(-psi,v)rotate([0,-90,60]){
            cylinder(r=Rpin+tol,h=R,$fn=12);
            translate([-Rpin-tol,0,0])cube([(Rpin+tol)*2,4,R]);
        }
        rotate(-psi,v)rotate([0,-90,56])cylinder(r=Rpin+tol,h=R,$fn=12);
    }
    union(){
        rotate(-psi,v)rotate([0,0,72])rotate(psi,v)
            translate([0,0,(W/2+tol)*sqrt(2)])cylinder(r1=0,r2=R,h=R);
        rotate([0,0,126])translate([0,0,-R])cube([R,R,2*R]);
    }
}

module outer()
intersection(){
    difference(){
        base();
        difference(){
            sphere(r=R-T);
            for(i=[0:4])rotate([0,-90,5+i*72])translate([0,0,R-2*T-tol])difference(){
                cylinder(r=Rpin,h=2*T,$fn=12);
                translate([-Rpin,-Rpin,T*.8])rotate([0,90+45,0])cube(2*Rpin);
            }
        }
        translate([0,0,-BaseH])cylinder(r1=R,r2=R-7,h=10);
    }
    translate([0,0,-BaseH])cylinder(r1=R-13,r2=3*R,h=2*R);
}

module inner()
render(convexity=6)
difference(){
    union(){
        intersection(){
            base();
            union(){
                sphere(r=R-2*T-2*tol);
                for(i=[0:4])
                rotate([0,phi-90,i*72])cylinder(r=Rpin1,h=R-T-tol,$fn=12);
            }
        }
        handle();
    }
    difference(){
        sphere(r=R-W);
        translate([0,0,-BaseH])cylinder(r=R,h=1);
    }
}

module handle()
translate([0,0,-BaseH])difference(){
    cylinder(r1=R+20,r2=R,h=7);
    difference(){
        for(i=[0:14])rotate([0,0,i*360/15])
            translate([R+20,0,34])rotate([90,0,0])rotate_extrude()difference(){
                translate([10,0])circle(r=30);
                translate([-50,0])square(100,center=true);
            }
        translate([0,0,BaseH])sphere(r=R);
    }
    difference(){
        translate([0,0,BaseH])sphere(r=R-T);
        for(i=[0:4])rotate([0,0,i*72])difference(){
            translate([10-R,Rhole*1,0])rotate([45,0,0])cube(10,center=true);
            translate([-R,Rhole+tol-20,-1])cube(20);
        }
    }
}

module base()
union(){
    difference(){
        sphere(r=R);
        cylinder(r1=0,r2=R,h=R);
        translate([0,0,-R-BaseH])cube(2*R,center=true);
    }
    rotate_extrude()translate((R-W/2)*sqrt(2)/2*[1,1])circle(r=W/2,$fn=20);
}

function Zto1(x)=(1-cos(x*360))/2;