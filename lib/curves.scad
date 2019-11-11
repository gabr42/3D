include <helpers.math.scad>
include <geometry.scad>

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
