include <helpers.math.scad>
use <helpers.lists.scad> 
use <geometry.scad>
use <geometry.manipulators.scad>

// Multi-segment straight line between two 3D points.

function make_segment_line(from, to) =
  let (segments = $fn > 0 ? $fn : 50,
      _from = make_3D(from),
      _to = make_3D(to),
      d = [(_to.x - _from.x)/segments, (_to.y - _from.y)/segments, (_to.z - _from.z)/segments])
  [for (i = [0:segments]) [_from.x + i * d.x, _from.y + i * d.y, _from.z + i * d.z]];
    
// Reqular polygon inscribed in a unit circle with one vertex at (1,0).
  
function make_unit_polygon(numsides) =
  [for (i = [0:numsides - 1]) point_on_unit_circle(360/numsides*i)];
  
// 3D sinusoidal wave, starting at [0,0], extending along x.

function make_wave(width, yheight, zheight, num_waves, yoffset = 0,zoffset = 0) = 
  let (segments = $fn > 0 ? $fn : 50)
  let (delta = width / segments)
  [for (i = [0:segments]) 
    [i*width/segments, 
     sin((i/segments) * 360 * num_waves - yoffset) * yheight, 
     sin((i/segments) * 360 * num_waves - zoffset) * zheight]];

// Logistic curve, scaled along x and y axes, translated on y axis to pass through (0,0).
  
function make_logistic_curve(x1, x2, xscale, yscale) = 
  let (segments = $fn > 0 ? $fn : 50)
  [for (i = [0:segments])
    let (x = x1 + (x2 - x1) / segments * i) 
    [x, yscale * (logistic_function(x / xscale) - 1/2)]];

// Offsets a curve and concats it to the original. Output can be plugged into a polygon().

function make_strip_points(offset, curve) = 
  concat(curve, reverse(g_translate(offset, curve)));

// Creates offset curves and concats them into a new curve.

function make_curve_replicas(offsets, curve) =
  ! is_vector(offsets)
    ? [for (offset = offsets) each make_curve_replicas(offset, curve)]
    : g_translate(offsets, curve);

// echo(make_curve_replicas([[1,0,0], [0,1,0]], [[2,2,2], [3,3,3]])); // [3, 2, 2], [4, 3, 3], [2, 3, 2], [3, 4, 3]

// Finds a closest point on a curve and returns point-on-curve and the segment index (starting from 0).

function _curve_fcp(curve, pt, idx, best) = // [pt_on_curve, segment_index, distance]
  let (pt1 = find_closest_point(curve[idx], curve[idx+1], pt),
       d1 =  distance(pt1, pt),
       b1 = is_undef(best) 
              ? [pt1, idx, d1]
              : d1 < best[2] 
                  ? [pt1, idx, d1] 
                  : best)
  idx == 0 ? b1 : _curve_fcp(curve, pt, idx - 1, b1);

function curve_find_closest_point(curve, pt) = // [pt_on_curve, segment_index, distance]
  assert(len(curve) > 1, "Curve must have at least one segment")
  let (tmp = _curve_fcp(curve, pt, len(curve) - 2, undef))
  tmp;

// curve = [[1,1], [2,3], [3, 5]];
// echo(curve_find_closest_point(curve, [2,2]));
// echo(curve_find_closest_point(curve, [2,3]));

// Returns length of a curve.

function curve_len(curve) = 
  sum_list([for (i = [0:1:len(curve)-2]) distance(curve[i], curve[i+1])]);

// Returns partial length from start of the curve to segment/point.

function curve_partial_len(curve, segment, pt) =
  sum_list([for (i = [0:1:segment-1]) distance(curve[i], curve[i+1])])
  + distance(pt, curve[segment]);
  
//echo(curve_partial_len([[0,0], [1,1], [2,2]], 1, [1.5, 1.5]));

// Finds [point, segment index] on curve for t = [0..1].

function _curve_fo(curve, offset, idx) =
  let (seg_len = length(curve[idx + 1] - curve[idx]))
  seg_len >= offset 
    ? [interpolate(offset/seg_len, curve[idx], curve[idx+1]), idx]
    : idx == len(curve) - 2
        ? [curve[len(curve)-1], idx]
        : _curve_fo(curve, offset - seg_len, idx + 1);

function curve_find_offset(curve, t) = // [pt_on_curve, segment_index]
  assert(len(curve) > 1, "Curve must have at least one segment")
  assert(t >= 0 && t <= 1, "T must lie between 0 and 1")
  _curve_fo(curve, t * curve_len(curve), 0);
  
// echo(curve_find_offset([[0,0], [1,1], [2,2], [3,3]], 0));
// echo(curve_find_offset([[0,0], [1,1], [2,2], [3,3]], 0.5));
// echo(curve_find_offset([[0,0], [1,1], [2,2], [3,3]], 1));
