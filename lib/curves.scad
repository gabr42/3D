function translate(points, dx, dy) = 
  [for (i = points) [i.x + dx, i.y + dy]];

function translate(points, dx, dy, dz) = 
  [for (i = points) [i.x + dx, i.y + dy, is_undef(i.z) ? dz : i.z + dz]];
    
function make_list(from, to) = 
  [for (i = [from:to]) i];
    
function reverse(list) = 
  [for (i = [len(list)-1:-1:0]) list[i]];
    
function wave_points(width, height, num_waves) = 
  let (steps = $fn > 0 ? $fn : 10)
  let (delta = width / steps)
  [for (i = [0:steps]) [i*width/steps, sin((i/steps)*360*num_waves) * height]];

function offset_wave(width, height, num_waves, offset) = 
  let (w1 = wave_points(width, height, num_waves))
  let (w2 = reverse(translate(w1, 0, offset)))
  concat(w1,w2);

wave = offset_wave(50, 5, 2, 3, $fn=81);

//color("red")
//polygon(wave);
//  
//color("green")
//translate([0, 3, 0])
//mirror([0, 1, 0])
//polygon(wave);

function wave_points_3d_sin(width, yheight, zheight, num_waves) = 
  let (steps = $fn > 0 ? $fn : 10)
  let (delta = width / steps)
  [for (i = [0:steps]) [i*width/steps, sin((i/steps)*360*num_waves) * yheight, sin((i/steps)*360*(num_waves/2)) * zheight]];

function wave_points_3d_cos(width, yheight, zheight, num_waves) = 
  let (steps = $fn > 0 ? $fn : 10)
  let (delta = width / steps)
  [for (i = [0:steps]) [i*width/steps, cos((i/steps)*360*num_waves) * yheight, cos((i/steps)*360*(num_waves/2)) * zheight]];
  
function snake_points(curve, dy, dz) = 
  concat(curve, 
    translate(curve, 0, dy, 0),
    translate(curve, 0, 0, dz),
    translate(curve, 0, dy, dz));
  
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
    
wsin = wave_points_3d_sin(80, 5, 5, 3, $fn = 50);

color("red")
polyhedron(snake_points(wsin, 5, 5), snake_faces(wsin));

wcos = wave_points_3d_cos(80, 5, 5, 3, $fn = 50);

color("green")
polyhedron(snake_points(wcos, 5, 5), snake_faces(wcos));

//color("green")
//mirror([0, 1, 0])
//polyhedron(concat(w1l, w2l, w1u, w2u), faces);
