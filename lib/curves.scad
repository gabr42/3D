use <helpers.scad>
    
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

function snake_points(curve, dy, dz) = 
  concat(curve, 
    translate(curve, [0, dy, 0]),
    translate(curve, [0, 0, dz]),
    translate(curve, [0, dy, dz]));
  
function snake_faces(curve) =
  let (o2 = len(curve))
  let (o1u = 2*o2)
  let (o2u = 3*o2)
  concat(
    [[0, o2, o2u, o1u]],
    [for (i = [0: o2-2])
      each([
        [i, o1u + i, o1u + i + 1, i + 1],      
        [o1u + i, o2u + i, o2u + i + 1, o1u + i + 1],
        [o2u + i, o2 + i, o2 + i + 1, o2u + i + 1],
        [o2 + i, i, i + 1, o2 + i + 1]
      ])],
    [[o2 - 1, o1u + o2 - 1, o2u + o2 - 1, o2 + o2 - 1]]
  );
 
module sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  wsin = wave_points_3d(length, yheight, zheight, num_waves, offset, offset + 90);
  polyhedron(snake_points(wsin, ythick, zthick), snake_faces(wsin));  
}
    

module test_sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  color("red")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset);
  
  color("green")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset + 180);
}

//test_sinus_spiral(80, 10, 5, 5, 5, 2, $fn=50);