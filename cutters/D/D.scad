use <../../lib/curves.scad>
include <../cutters.scad>

sizes = [10, 15, 20];
eccentricity = 0.65;

cutter_release = true;
// cutter_verbose = true;

$fn = 50;
$fa = 2;

module D_outline(radius, eccentricity) {
  arch = make_segment_ellipse([0,0], radius, eccentricity, -90, 90);
  polygon(curve_close(arch));
}

module D_wall(radius, eccentricity) {
  cutter_render_wall()
  D_outline(radius, eccentricity);
}
  
for (i = [0:len(sizes)-1]) {
  translate([i * (sizes[len(sizes)-1] + 10), 0, 0])
  D_wall(sizes[i], eccentricity);
}