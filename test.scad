use <lib/geometry.scad>
use <lib/curves.scad>
use <lib/mesh.scad>
use <lib/mesh.solids.scad>

$fn = 3;

b = make_segment_line([0,0,0], [0,0,30]);
b1 = concat(b, 
            translate(b, [3, 0, 0]),
            translate(b, [0, 3, 0]),
            translate(b, [3, 3, 0]));
//mesh_polyhedron(b1);

l = make_logistic_curve(-15, 15, 5, 20);

l1 = 
  mirror_X(
    rotate_mesh(
    rotate_mesh(l, 270, [0,0,0], [1,0,0]),
    90, [0,0,0], [0,1,0]));

l2 = translate(l1, -l1[0]);

mesh_polyhedron(make_band_points(l2, 3, 3));

b2 = reflow_mesh(b1, b, l2);

!mesh_polyhedron(b2);