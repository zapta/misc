/* [Basic] */

bottom_radius = 25;
curve_width = 12;
thickness = 2;
base_height = 1;

/* [Point0] */

px0 = 0;   // [-300:300]
py0 = 0;   // [-300:300]

/* [Point1] */

px1 = 8;  // [-300:300]
py1 = 12;  // [-300:300]

/* [Point2] */

px2 = 0;  // [-300:300]
py2 = 15;  // [-300:300]

/* [Point3] */

px3 = 0;   // [-300:300]
py3 = 28; // [-300:300]

/* [Advanced] */

fn = 40;
t_step = 0.05;

module line(point1, point2, width = 1) {
    angle = 90 - atan((point2[1] - point1[1]) / (point2[0] - point1[0]));
    offset_x = 0.5 * width * cos(angle);
    offset_y = 0.5 * width * sin(angle);

    offset1 = [-offset_x, offset_y];
    offset2 = [offset_x, -offset_y];


        translate(point1) circle(d = width, $fn = 24);
        translate(point2) circle(d = width, $fn = 24);


    polygon(points=[
        point1 + offset1, point2 + offset1,  
        point2 + offset2, point1 + offset2
    ]);
}

module polyline(points, width = 1) {
    module polyline_inner(points, index) {
        if(index < len(points)) {
            line(points[index - 1], points[index], width);
            polyline_inner(points, index + 1);
        }
    }

    polyline_inner(points, 1);
}

function bezier_coordinate(t, n0, n1, n2, n3) = n0 * pow((1 - t), 3) + 3 * n1 * t * pow((1 - t), 2) + 3 * n2 * pow(t, 2) * (1 - t) + n3 * pow(t, 3);

function bezier_point(t, p0, p1, p2, p3) = 
    [
        bezier_coordinate(t, p0[0], p1[0], p2[0], p3[0]),
        bezier_coordinate(t, p0[1], p1[1], p2[1], p3[1]),
        bezier_coordinate(t, p0[2], p1[2], p2[2], p3[2])
    ];
    

function bezier_curve(t_step, p0, p1, p2, p3) = [for(t = [0: t_step: 1 + t_step]) bezier_point(t, p0, p1, p2, p3)];

module bezier_vase(bottom_radius, curve_width, thickness,  p0, p1, p2, p3, fn, t_step) {
    $fn = fn;

    points = bezier_curve(t_step, p0, p1, p2, p3);


        rotate_extrude() 
            translate([bottom_radius, 0, 0]) 
                polyline(points, thickness);
    
    translate([0,0,-1])linear_extrude(height=base_height) circle(r = bottom_radius);

}

bezier_vase(
    bottom_radius, 
    curve_width, 
    thickness, 
    [px0, py0, 0], 
    [px1, py1, 0], 
    [px2, py2, 0], 
    [px3, py3, 0], 
    fn, 
    t_step
);
