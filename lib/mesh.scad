include <helpers.math.scad>
use <geometry.scad>
use <curves.scad>

// Generates a regular polygon, offset in y and z direction.

function make_polyhedron_mesh(radius, numSides, ywidth, zwidth) =
  let (p1o = make_unit_polygon(numSides) * radius,
       p1 = concat(p1o, [p1o[0]]),
       p2 = scale(p1, (radius - ywidth) / radius))
  concat(p2,
         p1,
         translate(p2, [0, 0, zwidth]),
         translate(p1, [0, 0, zwidth]));

// Wraps a mesh around the cylinder with radius r and axis [0, y, -r]. 

function wrap_point(pt, r) =
  let (alpha = 360 / (2 * pi * r) * pt.x)
  [(r + pt.z) * sin(alpha), pt.y, -r + (r+pt.z) * cos(alpha)];  
  
function wrap_around_cylinder(mesh, r) = 
  [for (pt = mesh) [each wrap_point(pt, r)]];

// Rotates a mesh around `origin` by `alpha` degrees along rotation axis `v`. Positive angle rotates CCW. Rotation is limited to XY plane.

function rotate_mesh(mesh, angle, origin = [0, 0, 0], v = [0, 0, 1]) = 
  [for (pt = mesh) rotate_point(pt, angle, origin, v)];

// Linear shear perpendicular to Z axis. `begin1/end1` segment is sheared to `begin2/end2` segment.
  
function zshear_mesh(mesh, begin1, end1, begin2, end2) = 
  let (dz1 = end1.z - begin1.z,
       dz2 = end2.z - begin2.z)
  [for (pt = mesh)
    let (k = (pt.z - begin1.z) / dz1,
         pt1 = interpolate(k, begin1, end1),
         pt2 = interpolate(k, begin2, end2))     
    [pt2.x + (pt.x - pt1.x), pt2.y + (pt.y - pt1.y), pt.z]
  ];

// Twist mesh along a curve.

function twist_mesh(mesh, curve, angle) =
  let (full_len = curve_len(curve))
  [for (pt = mesh) 
    let (find = curve_find_closest_point(curve, pt),
         pt_len = curve_partial_len(curve, find[1], find[0]))
    echo(pt_len/full_len)
    pt    
  ];

echo(  
twist_mesh([[1,1,1], [1,1,2], [1,1,3]], 
           [[0,0,0], [0,0,3]],
           90));

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
