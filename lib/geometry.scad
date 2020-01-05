/* Functions that implement calculations on points (2D/3D) and lists of points.
*/

use <helpers.lists.scad>
use <helpers.math.scad>
use <helpers.objects.scad>

// Calculates distance between two points.

function distance(pt1, pt2) =
  length(pt2 - pt1);
  
// Linear interpolation between two points.

function interpolate(t, pt1, pt2) = 
  (1 - t) * pt1 + t * pt2;
  
// Angle (0-180) between two (2D or 3D) vectors.

function angle(u, v) =
  let (u3 = make_3D(u),
       v3 = make_3D(v))
  angle3(u3, v3); 
  
// Angle (0-360) of a 2D vector.

function angle2(v1) = 
  let(side = dist_from_line(line_coef([0, 0], [1, 0]), v1),
      a = angle3(concat(v1, [0])))
  side <= 0 ? a : 360 - a; 

// Sets Z coordinate to 0 if it is not defined.

function make_3D(points) = 
  ! is_vector(points)
    ? [for (pt = points) make_3D(pt)]
    : is_undef(points.z) ? concat(points, 0) : points;
  
// echo(make_3D([1,1]));
// echo(make_3D([[1,1], [2,2,2]]));
    
// Removes Z coordinate.

function make_2D(points) = 
  ! is_vector(points)
    ? [for (pt = points) make_2D(pt)]
    : slice(points, [0:1]);
  
// Point on the unit circle on XY plane corresponding to `angle` (in degrees).
  
function point_on_unit_circle(angle) = [cos(angle), sin(angle)];

// Calculates center point for circle with radius `r` running through points `pt1` and `pt2`.
// The `side` parameter (1 or -1) determines on which side of the (pt1, pt2) line the center should lie.

function circle_center(pt1, pt2, r, side = 1) =
  let (mp = interpolate(0.5, pt1, pt2),
       mv = side == 1 ? turn_left(pt2 - mp) : turn_right(pt2 - mp),
       cp = mp + [mv.x, mv.y],
       td = sqrt(pow(r, 2) - pow(distance(pt2, pt1)/2, 2)))
  interpolate(td/distance(cp, mp), mp, cp);

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

function bb_create(p1, p2, p3, p4) = 
  // parameters: left, top, right, bottom
  //         or: [left bottom x, left bottom y], [right top x, right top y], undef, undef
  //         or: bb object, undef, undef, undef
  is_undef(p2)
    ? p1
    : is_undef(p3) && is_undef(p4)
        ? [p1.x, p2.y, p2.x, p1.y]
        : [p1, p2, p3, p4];

function bb_left(bb, __left) = __getset(bb, 0, __left);
function bb_top(bb, __top) = __getset(bb, 1, __top);
function bb_right(bb, __right) = __getset(bb, 2, __right);
function bb_bottom(bb, __bottom) = __getset(bb, 3, __bottom);

function bb_width(bb) = bb_right(bb) - bb_left(bb);

function bb_height(bb) = bb_top(bb) - bb_bottom(bb);

function bb_move_to(bb, left, top, right, bottom) =
  let(dx = is_undef(left) 
             ? is_undef(right)
                 ? undef
                 : right - bb_right(bb)
             : left - bb_left(bb),
      dy = is_undef(bottom)
             ? is_undef(top)
                 ? undef
                 : top - bb_top(bb)
             : bottom - bb_bottom(bb))
  bb_create(is_undef(dx) ? bb_left(bb) : bb_left(bb) + dx, 
            is_undef(dy) ? bb_top(bb) : bb_top(bb) + dy, 
            is_undef(dx) ? bb_right(bb) : bb_right(bb) + dx,
            is_undef(dy) ? bb_bottom(bb) : bb_bottom(bb) + dy);

function dot2(v1, v2) = 
  let (d = sqrt((pow(v1.x, 2) + pow(v1.y, 2))*(pow(v2.x, 2) + pow(v2.y, 22))))
  d == 0 
    ? 0
    : acos((v1.x * v2.x + v1.y * v2.y)/d);

function cross2(v1, v2) = 
  v1.x * v2.y - v2.x * v1.y;

// Returns a, b, c in ax + by + c = 0 for line going through (p1, p2). Assumes 2D points.
// Graphics Gems III/IV.5

function line_coef(p1, p2) = [
  p2.y - p1.y,
  p1.x - p2.x,
  p2.x * p1.y - p1.x * p2.y
];

// Returns signed distance from line l = ax + by + c = 0 to point p. Assumes 2D geometry.
// Graphics Gems III/IV.5

function dist_from_line(l, p) =
  let(d = hypoth(l[0], l[1]))
  d == 0
    ? 0
    : (l[0] * p.x + l[1] * p.y + l[2])/d;
    
// Given line l = ax + by + c = 0 and point p1, compute p2 so (p1, p2) is ⊥ to l.
// Graphics Gems III/IV.5

function point_perp(l, p1) = 
  let(d = pow(l[0], 2) + pow(l[1], 2),
      cp = l[0] * p1.y - l[1] * p1.x)
  d == 0
    ? [0, 0]
    : [(-l[0] * l[2] - l[1] * cp)/d,
       (l[0] * cp - l[1] * l[2])/d];

// Joins lines (p1, p2) and (p3, p4) with arc fillet of radius r.
// Returns [p2n, p3n, pc, sa, a] where
//  - p2n = new point p2
//  - p3n = new point p3
//  - pc = center of the arc
//  - sa = starting angle of the arc
//  - a = angle of the arc
// Graphics Gems III/IV.5

function fillet_lines (p1, p2, p3, p4, r) = 
  let(l1 = line_coef(p1, p2),
      l2 = line_coef(p3, p4))
  (l1[0] * l2[1]) == (l2[0] * l1[1])
    ? // Parallel lines
      [p2, p3, [undef, undef], undef, undef]
    : let (d1 = dist_from_line(l1, interpolate(0.5, p3, p4)), // Find d1 = distance (p1, p2) to midpoint (p3, p4).
           d2 = dist_from_line(l2, interpolate(0.5, p1, p2))) // Find d2 = instance (p3, p4) to midpoint (p1, p2).
      ((d1 == 0) || (d2 == 0))
        ? // Abnormal case
          [p2, p3, [undef, undef], undef, undef]
        : let(rr1 = d1 <= 0 ? -r : r, // Construct line ∏ to l at d.
              c1p = l1[2] - rr1 * hypoth(l1[0], l1[1]),  
              rr2 = d2 <= 0 ? -r : r,
              c2p = l2[2] - rr2 * hypoth(l2[0], l2[1]),
              d = l1[0] * l2[1] - l2[0] * l1[1], // Intersect constructed lines to find center of circular arc.
              pc = [(c2p * l1[1] - c1p * l2[1])/d,
                    (c1p * l2[0] - c2p * l1[0])/d],
              pta = point_perp(l1, pc), // Clip l1 at (xa, ya) if needed.
              ptb = point_perp(l2, pc), // Clip l2 at (xb, yb) if needed.
              v1 = pta - pc, // Find angle wrt. x-axis from arc center, (xc, yc).
              v2 = ptb - pc,
              pa = atan2(v1.y, v1.x),
              aa = cross2(v1, v2) >= 0 // Find angle arc subtends.
                     ? dot2(v1, v2)
                     : - dot2(v1, v2))
          [pta, ptb, pc, pa, aa];
