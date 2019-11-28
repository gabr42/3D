include <../../lib/helpers.math.scad>
use <../../lib/curves.scad>
include <../cutters.scad>

sizes = [[25, 10], [35, 10], [45, 10], [55, 10]];

 cutter_release = true;
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

module supports (straight, radius) {
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

module oval (straight, radius) {
  cutter_render_wall() 
  oval_2D(straight, radius);

  supports(straight, radius); 
}

for (i = [0:len(sizes)-1]) {
  translate([0, i*20, 0])
  oval(sizes[i].x - sizes[i].y, sizes[i].y/2);
}