include <helpers.scad>
    
function wave_points(length, height, num_waves, offset = 0) = 
  let (steps = $fn > 0 ? $fn : 10)
  let (delta = length / steps)
  [for (i = [0:steps]) [i*length/steps, sin((i/steps)*360*num_waves - offset) * height]];
  
function offset_wave(length, height, num_waves, thickness, offset) = 
  let (w1 = wave_points(length, height, num_waves, offset))
  let (w2 = reverse(translate(w1, [0, thickness])))
  concat(w1,w2);

module sinus_wave(length, height, thickness, num_waves, offset = 0) {
  polygon(offset_wave(length, height, num_waves, thickness, offset));
}

module test_sinus_wave(length, height, thickness, num_waves) {
  color("red")
  sinus_wave(length, height, thickness, num_waves);
    
  color("green")
  sinus_wave(length, height, thickness, num_waves, offset = 180);
}

//test_sinus_wave(50, 5, 2, 3, $fn=81);

function wave_points_3d(width, yheight, zheight, num_waves, yoffset = 0,zoffset = 0) = 
  let (steps = $fn > 0 ? $fn : 10)
  let (delta = width / steps)
  [for (i = [0:steps]) [i*width/steps, sin((i/steps)*360*num_waves - yoffset) * yheight, sin((i/steps)*360*num_waves - zoffset) * zheight]];
 
module sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  wsin = wave_points_3d(length, yheight, zheight, num_waves, offset, offset + 90);
  polyhedron(make_band_points(wsin, ythick, zthick), make_band_faces(wsin));  
}
    

module test_sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  color("red")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset);
  
  color("green")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset + 180);
}

//test_sinus_spiral(80, 10, 5, 5, 5, 2, $fn=50);

function wrap_point(pt, r) =
  let (alpha = 360 / (2 * pi * r) * pt.x)
  [(r + pt.z) * sin(alpha), pt.y, -r + (r+pt.z) * cos(alpha)];  
  
function wrap_around_cylinder(points, r) = 
  [for (pt = points) [each wrap_point(pt, r)]];
