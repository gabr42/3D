include <helpers.scad>
use <mesh.scad>
    
// 3D sinusoidal wave

function wave_points(width, yheight, zheight, num_waves, yoffset = 0,zoffset = 0) = 
  let (steps = $fn > 0 ? $fn : 10)
  let (delta = width / steps)
  [for (i = [0:steps]) [i*width/steps, sin((i/steps)*360*num_waves - yoffset) * yheight, sin((i/steps)*360*num_waves - zoffset) * zheight]];
 
module sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  wsin = make_band_points(
           wave_points(length, yheight, zheight, num_waves, offset, offset + 90),
           ythick, zthick);
  polyhedron(wsin, make_band_faces(wsin));  
}    

module test_sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  color("red")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset);
  
  color("green")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset + 180);
}

//test_sinus_spiral(80, 10, 5, 5, 5, 2, $fn=50);
