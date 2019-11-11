use <helpers.lists.scad>

// Calculates distance between two points.

function distance(pt1, pt2) =
  length(pt2 - pt1);
  
// Linear interpolation betwee two points.

function interpolate(k, pt1, pt2) = 
  [for (i = [0:1:len(pt1)-1]) pt1[i] + (pt2[i] - pt1[i]) * k];

// Calculates length of a vector.

function length(v) = sqrt(sum_squares(v));

// Normalizes a vector.

function normalize(v) = v / length(v);
  
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

// Sets Z coordinate to 0 if it is not defined

function Z0(pt) = 
  is_undef(pt.z) ? concat(pt, 0) : pt;

// Finds closest point on a segment.

function find_closest_point(from, to, pt) = 
  let(v = Z0(to) - Z0(from),
      u = Z0(from) - Z0(pt),
      vu = v*u,
      vv = v*v,
      t = -vu/vv)
  t >= 0 && t <= 1 ? interpolate(t, from, to)
                   : let (dF = distance(pt, from),
                          dT = distance(pt, to))
                     dF < dT ? from : to;

// Rotates point around `origin` for `angle` perpendicular to `v`.

function rotate_point(pt, origin, angle, v) =
  let (u = normalize(v),
       m = translate([pt], -1 * origin),
       c = cos(angle),
       s = sin(angle),
       R = [[c + u.x * u.x * (1 - c),         u.x * u.y * (1 - c) - u.z * s,  u.x * u.z * (1 - c) + u.y * s],
            [u.y * u.x * (1 - c) + u.z * s,   c + u.y * u.y * (1 - c),        u.y * u.z * (1 - c) + u.x * s],
            [u.z * u.x * (1 - c) + u.y * s,   u.z * u.y * (1 - c) + u.x * s,  c + u.z * u.z * (1 - c)]])
  translate([R * m[0]], origin)[0];

echo(rotate_point([1, 1, 1], [0, 0, 0], 90, [0, 0, 1])); // [-1, 1, 1]
echo(rotate_point([1, 1, 1], [1, 0, 0], 90, [0, 0, 1])); // [0, 0, 1]