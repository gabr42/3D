use <../lib/geometry.scad>
use <../lib/geometry.manipulators.scad>
use <../lib/curves.scad>
use <../lib/mesh.scad>
use <../lib/mesh.solids.scad>

height = 70;
radius = 20;
step = 7;
ring_height = height - 2*step;
numsides = 5;
xwidth = 1;
ywidth = 1;
zwidth = 1;
twist = 0; //720;

$fn = 30;

module rings (twist) {
  for (i = [0:step:ring_height]) {
    mesh_polyhedron(
      g_rotate(twist * i/height, points = 
      g_translate([0, 0, i], points = 
        make_polyhedron_mesh(radius * (height - i) / height, numsides, ywidth, zwidth)))
    );
  }
}

function make_deform_path() = 
  let (h1 = 30, r = 10, w1 = 20, h2 = 10)
  g_rotate(90, [0,0,0], [1, 0, 0],
    concat(make_segment_line([0,0], [0,h1]),
           make_segment_arc([r, h1], r, 180, 90),
           make_segment_line([r, h1 + r], [w1 + r, h1 + r]),
           make_segment_arc([w1 + r, h1 + 2 * r], r, -90, 0),
           make_segment_line([w1 + 2 * r, h1 + 2 * r], 
                             [w1 + 2 * r, h1 + h2 + 2 * r])));

visualize_curve(make_deform_path(), 0.5);

module tent (twist) {
  stick = make_curve_replicas([[0, 0, 0], [xwidth, 0, 0], [0, ywidth, 0], [xwidth, ywidth, 0]], 
            g_translate([-xwidth/2, -ywidth/2, 0], points =
              make_segment_line([0,0,0], [0,0,height])));
  for (pt = [0:1:numsides-1]) {
    v = point_on_unit_circle(360/numsides*pt) * (radius - xwidth/2);
    mesh_polyhedron(
      g_reflow([[0,0,0], [0,0,height]], make_deform_path(), points =
      g_twist([[0,0,0], [0,0,height]], twist, points = 
      g_zshear([0, 0, height], [0, 0, 0], [0, 0, height], [v.x, v.y, 0], points = 
        stick))));
  }
}

//rings(twist);
tent(twist);
//tent(-twist);
