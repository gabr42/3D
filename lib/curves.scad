include <helpers.math.scad>
use <helpers.lists.scad> 
use <geometry.scad>

// Multi-segment straight line between two 3D points.

function make_segment_line(from, to) =
  let (segments = $fn > 0 ? $fn : 50)
  let (d = [(to.x - from.x)/segments, (to.y - from.y)/segments, (to.z - from.z)/segments])
  [for (i = [0:segments]) [from.x + i * d.x, from.y + i * d.y, from.z + i * d.z]];
    
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

function make_strip_points(curve, offset) = 
  concat(curve, reverse(translate(curve, offset)));

// Finds a closest point on a curve and returns point-on-curve and the segment index (starting from 0).

function _curve_fcp(curve, pt, idx, best) = 
  let (pt1 = find_closest_point(curve[idx], curve[idx+1], pt),
       d1 =  distance(pt1, pt),
       b1 = is_undef(best) ? [pt1, d1, idx]
                           : d1 < best[1] ? [pt1, d1, idx] : best)
  idx == 0 ? b1 : _curve_fcp(curve, pt, idx - 1, b1);

function curve_find_closest_point(curve, pt) = // [pt_on_curve, distance, segment_index]
  assert(len(curve) > 1, "Curve must have at least one segment")
  let (tmp = _curve_fcp(curve, pt, len(curve) - 2, undef))
  [tmp[0], tmp[2]];

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
  