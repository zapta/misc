// Openscad script for 40mm PA test cube with a 'corner' at the rear.
bump = 0.2;
linear_extrude(40)
  polygon(points = [[-20, -20],  [20, -20], [20, 20], 
                    [0, 20+bump], [-20, 20],[-20, -20]]);
