use <../../lib/curves.scad>
include <../cutters.scad>

sizes = [[20, 15]];

// cutter_release = true;
// cutter_verbose = true;

$fn = 50;
$fa = 2;

module oval_2D (straight, radius) {
  polygon(
    concat(
      make_segment_arc([-straight/2,0], radius, 90, 270),
      make_segment_arc([straight/2, 0], radius, -90, 90))
  );
}

module oval_outline (straight, radius, offset) {
  difference () {
    offset(delta=offset)
    oval_2D (straight, radius);

    oval_2D (straight, radius);
  }
}

module oval (straight, radius) {
  cutter_render () 
  oval_outline(straight, radius, $cutter_layer_thickness);
 
 /* 
  t = straight/3;
  linear_extrude(2)
  union () {
    for (i = [-1:2:1], j = [-1:2:1]) 
      polygon([
        [i*-5*t/4 - 1, j*(radius + inf)], 
        [i*-5*t/4 + 1, j*(radius + inf)],
        [i*t/4 + 1, - j*(radius + inf)],
        [i*t/4 - 1, - j*(radius + inf)]
      ]);
  }
  */
}

for (xy = sizes) {
  oval(sizes[0].x - sizes[0].y, sizes[0].y/2);
}