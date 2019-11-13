use <../lib/helpers.math.scad>
use <../lib/geometry.scad>
use <../lib/geometry.manipulators.scad>
use <../lib/curves.scad>
use <../lib/mesh.scad>
use <../lib/mesh.solids.scad>

height = 70;
radius = 20;
step = 7;
ring_height = height - 2*step;
numsides = 11;
xwidth = 1.5;
ywidth = 1.5;
zwidth = 1.5;
twist = 360;

dplate = 10;
dplug = 3;
hplug = 6;
bwidth = 1;

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
  let (h1 = 20, r = 20, w1 = 20, h2 = 10)
  // echo ("Full height = ", h1 + h2 + 2 * r)
  g_rotate(90, [0,0,0], [1, 0, 0],
    concat(make_segment_line([0,0], [0,h1]),
           make_segment_arc([r, h1], r, 180, 90),
           make_segment_line([r, h1 + r], [w1 + r, h1 + r]),
           make_segment_arc([w1 + r, h1 + 2 * r], r, -90, 0),
           make_segment_line([w1 + 2 * r, h1 + 2 * r], 
                             [w1 + 2 * r, h1 + h2 + 2 * r])));

// visualize_curve(make_deform_path(), 0.5);

module tent (twist) {
  stick = 
    g_twist([[0,0,0], [0,0,height]], twist, points = 
      make_curve_replicas([[0, 0, 0], [xwidth, 0, 0], [0, ywidth, 0], [xwidth, ywidth, 0]], 
      g_translate([-xwidth/2, -ywidth/2, 0], points =
        make_segment_line([0,0,0], [0,0,height]))));

  for (pt = [0:1:numsides-1]) {
    v = point_on_unit_circle(360/numsides*pt) * (radius - xwidth/2);
    mesh_polyhedron(
      g_reflow([[0,0,0], [0,0,height]], make_deform_path(), points =
      g_twist([[0,0,0], [0,0,height]], twist, points = 
      g_zshear([0, 0, height], [0, 0, 0], [0, 0, height], [v.x, v.y, 0], points = 
        stick))));
  }
}

module base () {
  for (ipt1 = [0:1:numsides-1], ipt2 = [0:1:numsides-1]) {
    if (ipt1 > ipt2) {
      pt1 = make_3D(point_on_unit_circle(360/numsides*ipt1) * (radius - bwidth));
      pt2 = make_3D(point_on_unit_circle(360/numsides*ipt2) * (radius - bwidth));
      d = distance(pt1, pt2);
      line = make_band_points(              
               make_segment_line(pt1, pt1 + [d, 0, 0]), 
               bwidth, bwidth);
      mesh_polyhedron(
        g_rotate(angle([1,0,0], pt2-pt1) * sign(cross([1,0,0], pt2-pt1).z), pt1, points = line));
    }
  }
  
  linear_extrude(bwidth)
  circle(dplate / 2);
  
  translate([0, 0, -hplug + bwidth])
  linear_extrude(hplug)
  circle(dplug / 2);
  
  translate([-bwidth/2, 0, 0])
  mesh_polyhedron(
    make_polyhedron_mesh(radius + bwidth / 2, numsides, bwidth, bwidth));  
}

//rings(twist);
tent(twist);
tent(-twist);
base();