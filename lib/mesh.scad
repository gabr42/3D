include <helpers.math.scad>
use <geometry.scad>
use <geometry.manipulators.scad>
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
    rotate(pt, angle * pt_len/full_len, find[0], curve[find[1]+1] - curve[find[1]])
  ];

// Reflows mesh extending along source_path into new mesh extending along target_path.

function reflow_mesh(mesh, source_path, target_path) = 
  let (source_len = curve_len(source_path),
       target_len = curve_len(target_path))
  [for (pt = mesh) 
    let (nearest_s = curve_find_closest_point(source_path, pt),
         nearest_len = curve_partial_len(source_path, nearest_s[1], nearest_s[0]),
         nearest_t = curve_find_offset(target_path, nearest_len/source_len),
         u = source_path[nearest_s[1]+1] - source_path[nearest_s[1]],
         v = target_path[nearest_t[1]+1] - target_path[nearest_t[1]],
         pt_t = rotate(pt, angle(u, v), nearest_s[0], cross(v , u)))
    pt_t +  nearest_t[0] - nearest_s[0]];

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
