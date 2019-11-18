use <../../lib/curves.scad>
use <../../lib/mesh.solids.scad>
use <../../lib/helpers.lists.scad>

dbottom = 0.5;
dtop = 2.5;
height = 13;

sizes = [[50, 10]];

$fn = 50;
$fa = 1;

module oval_2D (straight, radius) {
  polygon(
    concat(
      make_segment_arc([-straight/2,0], radius, 90, 270),
      make_segment_arc([straight/2, 0], radius, -90, 90))
  );
}

module oval_outline (straight, radius) {
  difference () {
    offset(delta=dbottom)
    oval_2D (straight, radius);

    oval_2D (straight, radius);
  }
}

module oval (straight, radius, height) {
  translate([0, 0, height])
  rotate(180, [1,0,0])
  for (s = [100:105]) {
    linear_extrude(height, scale=s/100)
    oval_outline(straight, radius);
  }
}

for (i = [0:len(sizes)-1]) {
  //translate([1.1 * sum_list(slice(sizes, [0:1:i-1])), 0, 0])
  oval(sizes[i].x - sizes[i].y, sizes[i].y/2, height);
}