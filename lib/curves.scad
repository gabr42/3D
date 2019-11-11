include <helpers.scad>

// Multi-segment straight line between two 3D points.

function segment_line(from, to) =
  let (segments = $fn > 0 ? $fn : 50)
  let (d = [(to.x - from.x)/segments, (to.y - from.y)/segments, (to.z - from.z)/segments])
  [for (i = [0:segments]) [from.x + i * d.x, from.y + i * d.y, from.z + i * d.z]];
    
// Reqular polygon inscribed in a unit circle with one vertex at (1,0).
  
function unit_polygon(numsides) =
  [for (i = [0:numsides - 1]) point_on_unit_circle(360/numsides*i)];
  
// 3D sinusoidal wave, starting at [0,0], extending along x.

function wave_points(width, yheight, zheight, num_waves, yoffset = 0,zoffset = 0) = 
  let (segments = $fn > 0 ? $fn : 50)
  let (delta = width / segments)
  [for (i = [0:segments]) 
    [i*width/segments, 
     sin((i/segments) * 360 * num_waves - yoffset) * yheight, 
     sin((i/segments) * 360 * num_waves - zoffset) * zheight]];

// Logistic function and its derivative.

function logistic_function(x) = 
  let (ex = exp(x))
  ex / (ex + 1);

function logistic_function_dx(x) = 
  let (ex = exp(x))
  ex / ((ex + 1)*(ex + 1));
  
// Logistic curve, scaled along x and y axes, translated on y axis to pass through (0,0).
  
function logistic_curve(x1, x2, xscale, yscale) = 
  let (segments = $fn > 0 ? $fn : 50)
  [for (i = [0:segments])
    let (x = x1 + (x2 - x1) / segments * i) 
    [x, yscale * (logistic_function(x / xscale) - 1/2)]];
    
//polygon(logistic_curve([-10:1:10], 5, 2, 2));
