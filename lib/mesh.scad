include <helpers.math.scad>
use <geometry.scad>
use <geometry.manipulators.scad>
use <curves.scad>

// Generates a regular polygon, offset in y and z direction.

function make_polyhedron_mesh(radius, numSides, ywidth, zwidth) =
  let (p1o = make_unit_polygon(numSides) * radius,
       p1 = concat(p1o, [p1o[0]]),
       p2 = g_scale((radius - ywidth) / radius, points = p1))
  concat(p2,
         p1,
         g_translate([0, 0, zwidth], p2),
         g_translate([0, 0, zwidth], p1));

// Makes four copies of a list of points, offset in y, z, and y+z directions.
// Output can be plugged into polyhedron().    

function make_band_points(curve, dy, dz) = 
  make_curve_replicas([[0, 0, 0], [0, dy, 0], [0, 0, dz], [0, dy, dz]], curve);
  
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
