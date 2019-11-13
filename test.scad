use <lib/geometry.scad>
use <lib/geometry.manipulators.scad>
use <lib/curves.scad>
use <lib/mesh.scad>
use <lib/mesh.solids.scad>

$fn = 3;

b = make_segment_line([0,0,0], [0,0,30]);

visualize_curve(b, 0.3);

b1 = concat(b, 
            g_translate([3, 0, 0], b),
            g_translate([0, 3, 0], b),
            g_translate([3, 3, 0], b));
//mesh_polyhedron(b1);

l = make_logistic_curve(-15, 15, 5, 20);

l1 = 
  g_mirrorX(
    g_rotate(90, [0,0,0], [0,1,0],
    g_rotate(270, [0,0,0], [1,0,0], l)));

l2 = g_translate(-l1[0], l1);

visualize_curve(l2);

b2 = reflow_mesh(b1, b, l2);

//mesh_polyhedron(b2);  g