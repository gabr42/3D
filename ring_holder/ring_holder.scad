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
twist = 720;

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


module tent (twist) {
  stick = make_curve_replicas([[0, 0, 0], [xwidth, 0, 0], [0, ywidth, 0], [xwidth, ywidth, 0]], 
            g_translate([-xwidth/2, -ywidth/2, 0], points =
              make_segment_line([0,0,0], [0,0,height])));
  for (pt = [0:1:numsides-1]) {
    v = point_on_unit_circle(360/numsides*pt) * (radius - xwidth/2);
    mesh_polyhedron(
      g_twist([[0,0,0], [0,0,height]], twist, points = 
      g_zshear([0, 0, height], [0, 0, 0], [0, 0, height], [v.x, v.y, 0], points = 
        stick)));
  }
}

rings(twist);
tent(twist);
tent(-twist);
