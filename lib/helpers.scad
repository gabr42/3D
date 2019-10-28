// Constants

pi = 3.14159;
e = 2.71828;

// Creates a list of integers.

function make_list(from, to) = 
  [for (i = [from:to]) i];

// Reverses a list.
    
function reverse(list) = 
  [for (i = [len(list)-1:-1:0]) list[i]];

// Translates all points in a list by a specified offset.
// Supports 2D and 3D points. Supports 2D and 3D offsets.
// Offsetting a 2D point in 3 dimension creates a 3D point. Starting z is assumed to be 0.

function translate(points, offset) = 
  [for (i = points) is_undef(offset.z) ? [i.x + offset.x, i.y + offset.y] :
    [i.x + offset.x, i.y + offset.y, is_undef(i.z) ? offset.z : i.z + offset.z]];

// Makes four copies of a list of points, offset in y, z, and y+z directions.
// Output can be plugged into polyhedron().    

function make_band_points(curve, dy, dz) = 
  concat(curve, 
    translate(curve, [0, dy, 0]),
    translate(curve, [0, 0, dz]),
    translate(curve, [0, dy, dz]));
  
// Takes an output from make_band_points() and generates list of faces.
// Output can be plugged into polyhedron().
  
function make_band_faces(curve) =
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
