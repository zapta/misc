joinfactor = 0.125;

gFocalPoint = [0,0];
gSteps = 10;
gHeight = 4;

BezQuadCurve( [[0, 15],[5,5],[10,5],[15,15]], [7.5,0], gSteps, gHeight);

//=======================================
// Functions
//=======================================
function BEZ03(u) = pow((1-u), 3);
function BEZ13(u) = 3*u*(pow((1-u),2));
function BEZ23(u) = 3*(pow(u,2))*(1-u);
function BEZ33(u) = pow(u,3);

function PointAlongBez4(p0, p1, p2, p3, u) = [
	BEZ03(u)*p0[0]+BEZ13(u)*p1[0]+BEZ23(u)*p2[0]+BEZ33(u)*p3[0],
	BEZ03(u)*p0[1]+BEZ13(u)*p1[1]+BEZ23(u)*p2[1]+BEZ33(u)*p3[1]];

//=======================================
// Modules
//=======================================
// c - ControlPoints
module BezQuadCurve(c, focalPoint, steps=gSteps, height=gHeight)
{
	// Draw control points
	// Just comment this out when you're doing the real thing
	for(point=[0:3])
	{
		translate(c[point])
		color([1,0,0])
		cylinder(r=1, h=height+joinfactor);
	}

	for(step = [steps:1])
	{
		linear_extrude(height = height, convexity = 10) 
		polygon(
			points=[
				focalPoint,
				PointAlongBez4(c[0], c[1], c[2],c[3], step/steps),
				PointAlongBez4(c[0], c[1], c[2],c[3], (step-1)/steps)],
			paths=[[0,1,2,0]]
		);
	}
}

//==============================================
// Test functions
//==============================================
//PlotBEZ0(100);
//PlotBEZ1(100);
//PlotBEZ2(100);
//PlotBEZ3(100);
//PlotBez4Blending();


module PlotBEZ0(steps)
{
	cubeSize = 1;
	cubeHeight = steps;

	for (step=[0:steps])
	{
		translate([cubeSize*step, 0, 0])
		cube(size=[cubeSize, cubeSize, BEZ03(step/steps)*cubeHeight]);
	}	
}

module PlotBEZ1(steps)
{
	cubeSize = 1;
	cubeHeight = steps;

	for (step=[0:steps])
	{
		translate([cubeSize*step, 0, 0])
		cube(size=[cubeSize, cubeSize, BEZ13(step/steps)*cubeHeight]);
	}	
}

module PlotBEZ2(steps)
{
	cubeSize = 1;
	cubeHeight = steps;

	for (step=[0:steps])
	{
		translate([cubeSize*step, 0, 0])
		cube(size=[cubeSize, cubeSize, BEZ23(step/steps)*cubeHeight]);
	}	
}

module PlotBEZ3(steps)
{
	cubeSize = 1;
	cubeHeight = steps;

	for (step=[0:steps])
	{
		translate([cubeSize*step, 0, 0])
		cube(size=[cubeSize, cubeSize, BEZ33(step/steps)*cubeHeight]);
	}	
}

module PlotBez4Blending()
{
	sizing = 100;

	translate([0, 0, sizing + 10])
	PlotBEZ0(100);

	translate([sizing+10, 0, sizing + 10])
	PlotBEZ1(100);

	translate([0, 0, 0])
	PlotBEZ2(100);

	translate([sizing+10, 0, 0])
	PlotBEZ3(100);
}
