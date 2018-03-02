/******************************************************************************
 *
 *  GLOBALS
 *
 ******************************************************************************/


/* [General] */
gearType = 3; //[1: Regular gear, 2: Helix gear, 3: Double helix gear, 4: Herringbone gear]
// Radius from center to teeth base (!)
wheelRadius = 40;
outerThickness = 20;
innerThickness = 6;
// Inner/outer rings radius difference
outerRingThickness = 4;

/* [Inner Part] */
centerHole = 2; // [0: None, 1: Circular, 2: Hex]
// Not needed if no center hole
centerHoleDiameter = 10;

/* [Lightening Holes] */
lighteningHoles = 1; // [0: None, 1: Circular, 2: Wheelarm style]
// Not needed if no lightening holes
lighteningHolesCount = 6;
// Not needed if no lightening holes
lighteningHolesDistance = 4;
// Not needed if no lightening holes
lighteningHolesOuterDistance = 2;
// Needed only for wheelarm style holes
wheelarmHolerRoundness = 2;

/* [Teeth configuration] */
// Not needed for regular gear
herringboneAngle = 15; 
// Needed only for herringbone gear
herringboneSpaceWidth = 2;
teethCount = 44;
toothHeight = 4;
toothBaseWidth = 4;
toothEnd = 2; // [1: Flat, 2: Rounded]
toothEndWidth = 2;

/* [Hidden] */
$fa = 1;
$fs = 0.5;


/******************************************************************************
 *
 *  EXECUTION
 *
 ******************************************************************************/


ringsPart();
teethPart();


/******************************************************************************
 *
 *  DIRECT MODULES
 *
 ******************************************************************************/


module teethPart()
{
    if(gearType == 2)
    {
        _helixGear();
    }
    else if(gearType == 3)
    {
        _doubleHelixGear();
    }
    else if(gearType == 4)
    {
        _herringboneGear();
    }
    else
    {
        _regularGear();
    }
}

module ringsPart()
{
    difference()
    {
        _gearRings();
        union()
        {
            _centerHole();
            _lightening();
        }
    }
}


/******************************************************************************
 *
 *  HELPER AND COMPONENT MODULES
 *
 ******************************************************************************/


module _regularGear()
{
    _halfGear();
    translate([0, 0, outerThickness / 2]) 
        _halfGear();    
}

module _helixGear()
{
    _halfGear(herringboneAngle);
    translate([0, 0, outerThickness / 2])    
        rotate([0, 0, -herringboneAngle])
            _halfGear(herringboneAngle);
}

module _doubleHelixGear()
{
    _halfGear(-herringboneAngle);
    translate([0, 0, outerThickness / 2])    
        rotate([0, 0, herringboneAngle])
            _halfGear(herringboneAngle);
}

module _herringboneGear()
{
    difference()
    {
        _doubleHelixGear();
        _herringboneSpace();
    }   
}

module _minkowskiInside(mask = [9999, 9999]) // "Intel Inside"! No...
{
    minkowski()
    {
        difference()
        {
            square(mask, center = true);
            minkowski()
            {
                difference()
                {
                    square(mask, center = true);
                    children(0);
                }
                children(1);
            }
        }
        children(1);
    }
}


module _pie2d(angle, radius)
{
    if(angle > 90)
    {
        for(i = [1: 90: angle - (angle % 90)])
        {
            rotate([0, 0, i])
                _pie2d(90, radius);
        }
        
        rotate([0, 0, angle - (angle % 90)])
            _pie2d(angle % 90, radius);
    }
    else
    {
        rotate([0, 0, 90])
            intersection()
            {
                circle(radius);
                scale([2, 2, 1])
                    hull()
                    {
                        rotate([90, 0, 0])
                            square([radius, 44]); // no idea, why, but less than 10 kills OpenSCAD :)
                        rotate([90, 0, angle])
                            square([radius, 44]);
                    }
            }
    }
}


module _herringboneSpace()
{
        translate([0, 0, outerThickness / 2 - herringboneSpaceWidth / 2])
            difference()
                {
                    cylinder(r = wheelRadius + toothHeight + 4, h = herringboneSpaceWidth);
                    translate([0, 0, -1])
                        cylinder(r = wheelRadius - outerRingThickness / 2, h = herringboneSpaceWidth + 2);
                }
}

module _halfGear(twist = 0)
{
    linear_extrude(height = outerThickness / 2, twist = twist, convexity = 8)
        for(i = [0: 360 / teethCount: 360])
            rotate([0, 0, i])
                translate([wheelRadius, 0, 0])
                    _tooth();
}

module _tooth()
{
    union()
    {
        if(toothEnd == 1)
        {
            polygon([
                [0, toothBaseWidth / 2], [0, -toothBaseWidth / 2], [toothHeight, -toothEndWidth / 2], [toothHeight, toothEndWidth / 2]
            ]);
        }
        else
        {
            flatPartHeight = toothHeight - toothEndWidth / 2;
            union()
            {
                polygon([
                    [0, toothBaseWidth / 2], [0, -toothBaseWidth / 2], [flatPartHeight, -toothEndWidth / 2], [flatPartHeight, toothEndWidth / 2]
                ]);
                translate([flatPartHeight, 0, 0])
                    circle(toothEndWidth / 2);
            }
        }
        translate([-outerRingThickness/8, 0, 0])
            square([outerRingThickness/4, toothBaseWidth], center = true); // getting rid of freespaces the ugly-way
    }
}

module _lightening()
{
    if(lighteningHoles > 0)
    {
        angle = 360 / (lighteningHolesCount);
        for(i = [1 : lighteningHolesCount])
        {
            rotate([0, 0, angle * i])
            {
                if(lighteningHoles == 1)
                {
                    arm = wheelRadius - outerRingThickness;
                    // OMFG! It's been ages since I used trigonometry! 
                    holeRadius = arm * sin(angle / 2) / (1 + sin(angle / 2)) - lighteningHolesDistance / 4 - lighteningHolesOuterDistance / 2;
                    translate([wheelRadius - outerRingThickness - holeRadius - lighteningHolesOuterDistance, 0, 0])
                        cylinder(r = holeRadius, h = innerThickness + outerThickness, $fn = (lighteningHoles == 2 ? 3 : $fn));
                }      
                else
                {
                    innerRadius = wheelRadius - outerRingThickness - lighteningHolesOuterDistance;
                    distanceAngle = lighteningHolesDistance * 180 / (PI * innerRadius / 2);
                    linear_extrude(height = 40, convexity = 8)
                        _minkowskiInside()
                        {
                            difference()
                            {
                                difference()
                                {
                                    _pie2d(angle, innerRadius);
                                    circle(centerHoleDiameter / 2 + lighteningHolesDistance);
                                }
                                _pie2d(distanceAngle, innerRadius);
                            }
                            circle(wheelarmHolerRoundness);
                        }
                }
            }
        }
    }
}


module _centerHole()
{
    if(centerHole > 0)
    {
        translate([0, 0, -1])
            cylinder(r = centerHoleDiameter / 2, h = innerThickness + outerThickness, $fn = (centerHole == 2 ? 6 : $fn));
    }
}

module _gearRings()
{
    if(outerThickness > innerThickness)
    {
        difference()
        {
            _outerGear();
            _innerGearNegative();
        }
    }
    else 
    {
        _outerGear();
        if(outerThickness < innerThickness)
        {
            _innerGearPositive();
        }
    }
}

module _outerGear()
{
    cylinder(r = wheelRadius, h = outerThickness);
}

module _innerGearNegative()
{
        union()
        {
            translate([0, 0, (outerThickness - innerThickness) / 2 + innerThickness])
                cylinder(r = wheelRadius - outerRingThickness, h = outerThickness);
            translate([0, 0, -(outerThickness - innerThickness) / 2 - innerThickness])
                cylinder(r = wheelRadius - outerRingThickness, h = outerThickness);
        }    
}

module _innerGearPositive()
{
    translate([0, 0, (outerThickness - innerThickness) / 2])
        cylinder(r = wheelRadius - outerRingThickness, h = innerThickness);
}