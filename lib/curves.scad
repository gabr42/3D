include <helpers.scad>

// Multi-segment straight line between two 3D points.

function segment_line(from, to) =
  let (segments = $fn > 0 ? $fn : 50)
  let (d = [(to.x - from.x)/segments, (to.y - from.y)/segments, (to.z - from.z)/segments])
  [for (i = [0:segments]) [from.x + i * d.x, from.y + i * d.y, from.z + i * d.z]];
    
// 3D sinusoidal wave, starting at [0,0], extending along x.

function wave_points(width, yheight, zheight, num_waves, yoffset = 0,zoffset = 0) = 
  let (segments = $fn > 0 ? $fn : 50)
  let (delta = width / segments)
  [for (i = [0:segments]) [i*width/segments, sin((i/segments)*360*num_waves - yoffset) * yheight, sin((i/segments)*360*num_waves - zoffset) * zheight]];
 
