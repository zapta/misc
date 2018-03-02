
slices = max(10, 90/4);  // changing the 90 or 4 'fixes' the problem
height = 100;
d1 = 21;
d2 = 30; 
dr = (d2-d1)/2;
R = (dr*dr + height*height/4) / (2 * dr);

function radius_at_height(h) =
  let (dz = (h - height/2))
  (d2/2 - (R - sqrt(R*R - dz*dz)));  

function contour_points(extra_r, i=0) =
  let(h = i * height / slices)
  let(r = radius_at_height(h) + extra_r)
  (i == slices)
    ?  [[r, h]]
    :  concat([[r, h]], contour_points(extra_r, i+1));

echo("ww", contour_points(0));








