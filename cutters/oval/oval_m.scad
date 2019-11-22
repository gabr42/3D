include <../../lib/helpers.math.scad>
use <../../lib/helpers.lists.scad>
use <../../lib/curves.scad>
use <../../lib/mesh.solids.scad>

dbottom = 0.4;
dtop = 2;
height = 13;
extra = 1;
delta = 0.1;
sizes = [[20, 15]];

$fn = 50;
$fa = 2;

module around() {
  rotate_extrude(angle=360)
  polygon([[0,0], [0, 13], [0.05, 13], [0.05, 11], [1.25, 0]]);
}

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
    oval_2D(straight, radius);

    oval_2D(straight, radius);
  }
}

module oval (straight, radius) {
 
  difference () {
    render() minkowski () {
      linear_extrude(inf)
      oval_outline(straight, radius, 0.1);
     
      around();
    }
    
    translate([0, 0, -1])
    linear_extrude(height + extra + 1)
    oval_2D(straight, radius-0.1);
  }
}
 
module criss_cross(straight, radius) {
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
}

for (xy = sizes) {
  oval(sizes[0].x - sizes[0].y, sizes[0].y/2);
}