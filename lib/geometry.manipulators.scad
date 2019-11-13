/* Functions for manipulating points (2D/3D) and lists of points.
*/

use <helpers.math.scad>
use <helpers.lists.scad>
use <geometry.scad>

// Translates 2D/3D point or points by a specified offset.
// Offsetting a 2D point in 3 dimensions creates a 3D point.
// Offsetting a 3D point in 2 dimensions creates a 2D point.

function translate(points, offset) = 
  is_vector(points)
  ? let (pt = points)
    is_undef(offset.z) ? [pt.x + offset.x, pt.y + offset.y] 
                       : [pt.x + offset.x, pt.y + offset.y, make_3D(pt).z + offset.z]
  : [for (pt = points) translate(pt, offset)];
  
// echo(translate([[1,1], [1,1,1]], [1,1]));    // [2,2], [2,2]
// echo(translate([[1,1], [1,1,1]], [1,1,1]));  // [2,2,1], [2,2,2]
  
// Scales all points relatively to an optional `origin` (default = [0,0,0]). Supports 2D and 3D points.
  
function scale(points, factor, origin) = 
  [for (i = points) 
     is_undef(origin) 
       ? i * factor
       : (i - origin) * factor + origin];

// Mirrors x => -x. Supports 2D and 3D points.

function mirror_X(points) = 
  [for (pt = points) 
     is_undef(pt.z) ? [-pt.x, pt.y] : [-pt.x, pt.y, pt.z]];

// Mirrors y => -y. Supports 2D and 3D points.

function mirror_Y(points) = 
  [for (pt = points) 
     is_undef(pt.z) ? [pt.x, -pt.y] : [pt.x, -pt.y, pt.z]];

// Mirrors z => -z. Supports 3D points.

function mirror_Z(points) = 
  [for (pt = points) [pt.x, pt.y, -pt.z]];

// Rotates 2D/3D point or points around `origin` by `alpha` degrees along rotation axis `v`.

function rotate(points, angle, origin = [0, 0, 0], v = [0, 0, 1]) = 
  is_vector(points)
  ? let (pt = points,
         u = normalize(v),
         m = translate([pt], -1 * origin),
         c = cos(angle),
         s = sin(angle),
         R = [[c + u.x * u.x * (1 - c),         u.x * u.y * (1 - c) - u.z * s,  u.x * u.z * (1 - c) + u.y * s],
              [u.y * u.x * (1 - c) + u.z * s,   c + u.y * u.y * (1 - c),        u.y * u.z * (1 - c) + u.x * s],
              [u.z * u.x * (1 - c) + u.y * s,   u.z * u.y * (1 - c) + u.x * s,  c + u.z * u.z * (1 - c)]])
    translate([R * m[0]], origin)[0]
  : [for (pt = points) rotate(pt, angle, origin, v)];  

// echo(rotate([1, 1, 1], 90)); // [-1, 1, 1]
// echo(rotate([1, 1, 1], 90, [1, 0, 0], [0, 0, 1])); // [0, 0, 1]

// Wraps 2D/3D point or points around the cylinder with radius r and axis [0, y, -r]. 

function wrap_around_cylinder(points, r) = 
  is_vector(points)
  ? let (pt = make_3D(points),
         alpha = 360 / (2 * PI * r) * pt.x)
    [(r + pt.z) * sin(alpha), pt.y, -r + (r+pt.z) * cos(alpha)]
  : [for (pt = points) wrap_around_cylinder(pt, r)];
