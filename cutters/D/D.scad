use <../../lib/curves.scad>
use <../../lib/layout.scad>
use <../../lib/geometry.scad>
include <../cutters.scad>

sizes = [10, 15, 20];
eccentricity = 0.7;

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

module make_D(sizes, pos, layout) {  
  pos = is_undef(pos) ? 0 : pos;
  if (pos < len(sizes)) {
    size = sizes[pos];  
  
    new_layout = layout_right(layout, 10, __bb_create(0, size/2, size*1.5, -size/2));
    
    translate(new_layout[0])
    D_wall(size, eccentricity);
    
    make_D(sizes, pos + 1, new_layout);
  }
}

make_D(sizes);
