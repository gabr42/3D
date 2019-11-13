/* Functions that implement calculations on points (2D/3D) and lists of points.
*/

use <helpers.lists.scad>
use <helpers.math.scad>

// Calculates distance between two points.

function distance(pt1, pt2) =
  length(pt2 - pt1);
  
// Linear interpolation between two points.

function interpolate(t, pt1, pt2) = 
  (1 - t) * pt1 + t * pt2;

// Sets Z coordinate to 0 if it is not defined.

function make_3D(pt) = 
  is_undef(pt.z) ? concat(pt, 0) : pt;
  
// Point on the unit circle on XY plane corresponding to `angle` (in degrees).
  
function point_on_unit_circle(angle) = [cos(angle), sin(angle)];

// Finds closest point on a segment.

function find_closest_point(from, to, pt) = 
  let(v = make_3D(to) - make_3D(from),
      u = make_3D(from) - make_3D(pt),
      vu = v*u,
      vv = v*v,
      t = -vu/vv)
  t >= 0 && t <= 1 
    ? interpolate(t, from, to)
    : let (dF = distance(pt, from),
           dT = distance(pt, to))
      dF < dT ? from : to;
