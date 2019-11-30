include <../lib/helpers.math.scad>
use <../lib/curves.scad>
use <../lib/geometry.scad>
use <../lib/geometry.manipulators.scad>
use <../lib/mesh.scad>
use <../lib/mesh.solids.scad>
use <../lib/solids.scad>

length = 26;
length_u = 40;
yscale = 1.5;
zscale = 2;
width = 3;
height = 5;
spacing = 8.3;
spacing_v = 21;
angle_v = 11;
angle_shift = 10;
shift_out = 10;

shift = sin(angle_shift) * (spacing_v/2)/sin(90-angle_shift);

l = make_logistic_curve(-length/2, length/2, zscale, yscale, $fn=50);
l1 = g_translate([0, - l[0].y, 0], l);

module prong (cutoff = true) {
  difference () {
    mesh_polyhedron(make_band_points(l1, width, height));

    if (cutoff) {
      translate([-length/15, 0.5, -1])
      translate([0, -width, 0])
      translate(l1[0])
      rotate(-7)
      cube([length/5, width, height + 2]);
    }
  }
}

color("red")
translate([0, spacing/2, 0])
difference () {
  prong();

  inf = 0.1;

  len_lower = 13;

  translate([-length/2 + len_lower, 0, height - 2])
  rotate(-45, [0, 1, 0])
  cube([3, width + 4, 3]);

  translate([-length/2 - inf, -1, height - 2])
  cube([len_lower + inf, width + 3, 3]);
}

color("green")
translate([0, - spacing/2, 0])
mirror([0,1,0])
prong();

h = l1[len(l1)-1].y + spacing/2 + width;

color("blue")
translate([length/2 - 8, -h, 0])
cube([8, 2*h, height]);

color("lime")
difference () {
  l = make_logistic_curve(-length_u/2, length_u/2, zscale, yscale, $fn=50);
  l1 = g_translate([0, - l[0].y, 0], l);

  color("lime")
  translate([length/2 + shift_out, - height/2 + shift, - spacing_v])
  rotate(- angle_v, [0,1,0])
  translate([0, 0, - width])
  rotate(180, [0,0,1])
  rotate(90, [1,0,0])
  translate([length_u/2, 0, 0])
  mesh_polyhedron(make_band_points(l1, width, height));

  translate([length/2 + shift_out, - height/2 - 1 + shift, - spacing_v - width - 1])
  cube([width, height + 2, width + 2]);
}

module cross_sec () {
  translate([length/2 - height/2, 0, 0])
  scale(height/2 * sqrt(2))
  rotate(45)
  linear_extrude(inf)
  polygon(make_unit_polygon(4));
}

color("orange")
hull_chain () {
  translate([0, -h + height/2, 0])
  cross_sec();

  translate([shift_out, shift, - spacing_v/2])
  cross_sec();

  translate([shift_out, shift, - 2 * spacing_v/2 - width])
  cross_sec();
}

color("orange")
hull () {
  translate([0, h - height/2, 0])
  cross_sec();

  translate([shift_out, shift, - spacing_v/2])
  cross_sec();
}