include <../../lib/helpers.math.scad>
use <../../lib/curves.scad>
use <../../lib/geometry.scad>
use <../../lib/layout.scad>
include <../cutters.scad>

ratio = 1.5;
sizes = [40, 31, 34/ratio, 15];
x_r_corner_ratio = 3 / sizes[0];
support_size = 2;

// cutter_release = true;
// cutter_verbose = true;

$fn = 50;
$fa = 2;

module roundrect_2D (width, height, radius) {
  polygon(
    make_rounded_rect(width, height, radius)
  );
}

module supports (width, height) {
  t2 = height/2;
  t6 = height/6;
  s2 = support_size / 2;
  
  linear_extrude(2)
  union () {
    for (i = [-1:1:1]) {
      polygon([
        [0,     t2 + i * t6 + s2],
        [width, t2 + i * t6 + s2],
        [width, t2 + i * t6 - s2],
        [0,     t2 + i * t6 - s2]
      ]);
    }
  }
}

module roundrect_wall (width, height, radius) {
  cutter_render_wall() 
  roundrect_2D(width, height, radius);

  supports(width, height); 
}

module make_roundrect(sizes, pos, layout) {  
  pos = is_undef(pos) ? 0 : pos;
  if (pos < len(sizes)) {
    size = sizes[pos];  
  
    new_layout = layout_right(layout, 10, __bb_create(0, size*ratio, size, 0));
    
    translate(new_layout[0])
    roundrect_wall(size, size * ratio, size * x_r_corner_ratio);
    
    make_roundrect(sizes, pos + 1, new_layout);
  }
}

make_roundrect(sizes);
