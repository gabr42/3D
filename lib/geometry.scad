use <helpers.lists.scad>

// Calculates distance between two points.

function distance(pt1, pt2) =
  sqrt(sum_squares(pt2 - pt1));
  
// Linear interpolation betwee two points.

function interpolate(k, pt1, pt2) = 
  [for (i = [0:1:len(pt1)-1]) pt1[i] + (pt2[i] - pt1[i]) * k];
  
// Point on the unit circle on XY plane corresponding to `angle` (in degrees).
  
function point_on_unit_circle(angle) = [cos(angle), sin(angle)];

// Translates all points by a specified offset.
// Supports 2D and 3D points. Supports 2D and 3D offsets.
// Offsetting a 2D point in 3 dimensions creates a 3D point.
// Offsetting a 3D point in 2 dimensions creates a 2D point.
// Starting z is assumed to be 0.

function translate(points, offset) = 
  [for (i = points) 
     is_undef(offset.z) ? [i.x + offset.x, i.y + offset.y] 
                        : [i.x + offset.x, i.y + offset.y, is_undef(i.z) ? offset.z : i.z + offset.z]
  ];
  
// Scales all points relatively to (0,0) (or around an optional `origin`).
  
function scale(points, factor, origin) = 
  [for (i = points) is_undef(origin) ? i * factor
                                     : (i - origin) * factor + origin];
