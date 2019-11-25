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

function make_3D(points) = 
  ! is_vector(points)
    ? [for (pt = points) make_3D(pt)]
    : is_undef(points.z) ? concat(points, 0) : points;
  
// echo(make_3D([1,1]));
// echo(make_3D([[1,1], [2,2,2]]));
    
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

// Bounding box.

function __bb_create(__left, __top, __right, __bottom) =
  [__left, __top, __right, __bottom];

function __bb_left(bb, __left = undef) =
  is_undef(__left)
    ? bb[0]
    : concat(__left, bb[1], bb[2], bb[3]);

function __bb_top(bb, _top = undef) =
  is_undef(_top)
    ? bb[1]
    : concat(bb[0], _top, bb[2], bb[3]);

function __bb_right(bb, _right = undef) =
  is_undef(_right)
    ? bb[2]
    : concat(bb[0], bb[1], _right, bb[3]);

function __bb_bottom(bb, _bottom = undef) =
  is_undef(_bottom)
    ? bb[3]
    : concat(bb[0], bb[1], bb[2], _bottom);

function __bb_width(bb) = __bb_right(bb) - __bb_left(bb);

function __bb_height(bb) = __bb_top(bb) - __bb_bottom(bb);
