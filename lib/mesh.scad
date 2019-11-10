include <helpers.scad>

// Translates all points in a mesh by a specified offset.
// Supports 2D and 3D points. Supports 2D and 3D offsets.
// Offsetting a 2D point in 3 dimensions creates a 3D point.
// Offsetting a 3D point in 2 dimensions creates a 2D point.
// Starting z is assumed to be 0.

function translate(mesh, offset) = 
  [for (i = mesh) is_undef(offset.z) ? [i.x + offset.x, i.y + offset.y] :
    [i.x + offset.x, i.y + offset.y, is_undef(i.z) ? offset.z : i.z + offset.z]];
  
// Scales all points in a mesh relatively to (0,0)
  
function scale(mesh, factor) = [for (i = mesh) i * factor];

// Wraps a mesh around the cylinder with radius r and axis [0, y, -r]. 

function wrap_point(pt, r) =
  let (alpha = 360 / (2 * pi * r) * pt.x)
  [(r + pt.z) * sin(alpha), pt.y, -r + (r+pt.z) * cos(alpha)];  
  
function wrap_around_cylinder(mesh, r) = 
  [for (pt = mesh) [each wrap_point(pt, r)]];

// Rotates a mesh around [0, 0, 1] by `alpha` degrees. Positive angle rotates CCW.

function rotate_point(pt, alpha) =
  let (ca = cos(alpha))
  let (sa = sin(alpha))
  is_undef(pt.z) ? [pt.x * ca - pt.y * sa, pt.y * ca + pt.x * sa]
                 : [pt.x * ca - pt.y * sa, pt.y * ca + pt.x * sa, pt.z];

function rotate_mesh(mesh, alpha) = 
  [for (pt = mesh) [each rotate_point(pt, alpha)]];

// Makes four copies of a list of points, offset in y, z, and y+z directions.
// Output can be plugged into polyhedron().    

function make_band_points(curve, dy, dz) = 
  concat(     curve, 
    translate(curve, [0, dy, 0]),
    translate(curve, [0, 0, dz]),
    translate(curve, [0, dy, dz]));
  
// Takes an output from make_band_points() and generates list of faces.
// Output can be plugged into polyhedron().
  
function make_band_faces(mesh, closed = false) =
  let (num = len(mesh) / 4)
  let (b1l = 0 * num)
  let (b2l = 1 * num)
  let (b1u = 2 * num)
  let (b2u = 3 * num)
  let (last = closed ? num - 2 : num - 1)
  concat(
    [for (i = [0 : last - 1])
       each([
         [i + b1l, i + b1u, i + 1 + b1u, i + 1 + b1l],      
         [i + b1u, i + b2u, i + 1 + b2u, i + 1 + b1u],
         [i + b2u, i + b2l, i + 1 + b2l, i + 1 + b2u],
         [i + b2l, i + b1l, i + 1 + b1l, i + 1 + b2l]
       ])],
    closed ? [ [last + b1l, last + b1u, 0 + b1u, 0 + b1l],      
               [last + b1u, last + b2u, 0 + b2u, 0 + b1u],
               [last + b2u, last + b2l, 0 + b2l, 0 + b2u],
               [last + b2l, last + b1l, 0 + b1l, 0 + b2l] ] 
           : [ [b1l, b2l, b2u, b1u],
               [num - 1 + b1l, num - 1 + b1u, num - 1 + b2u, num - 1 + b2l] ]
  );
