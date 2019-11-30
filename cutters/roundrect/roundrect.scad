include <../../lib/helpers.math.scad>
use <../../lib/curves.scad>
use <../../lib/geometry.scad>
use <../../lib/layout.scad>
include <../cutters.scad>

ratio = 1.5;
sizes = [40, 31, 34/ratio, 15];
x_r_corner_ratio = 3 / sizes[0];

// cutter_release = true;
// cutter_verbose = true;

$fn = 50;
$fa = 2;

module roundrect_2D (width, height, radius) {
  polygon(
    make_rounded_rect(width, height, radius)
  );
}

module supports (straight, height, radius) {
  t = straight/3;
//  w2 = straight/20;p
  w2 = sqrt(pow(2*radius,2) + pow(3/2*t, 2))/(2*radius) * 0.7;
  
  linear_extrude(2)
  union () {
    for (i = [-1:2:1], j = [-1:2:1]) {
      polygon([
        [i*-5*t/4 - w2, j*(radius + inf)], 
        [i*-5*t/4 + w2, j*(radius + inf)],
        [i*t/4 + w2,  - j*(radius + inf)],
        [i*t/4 - w2,  - j*(radius + inf)]
      ]);
    }
  }
}

module roundrect_wall (width, height, radius) {
  cutter_render_wall() 
  roundrect_2D(width, height, radius);

  supports(width, height, radius); 
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
