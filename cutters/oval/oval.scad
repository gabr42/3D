use <../../lib/curves.scad>
use <../../lib/mesh.solids.scad>
use <../../lib/helpers.lists.scad>

dbottom = 0.5;
dtop = 2.5;
height = 13;
delta = 0.05;
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

module oval_outline (straight, radius, offset) {
  difference () {
    offset(delta=offset)
    oval_2D (straight, radius);

    oval_2D (straight, radius);
  }
}

module oval (straight, radius) {
  hd = height / (dtop - dbottom) * delta;
  //echo(str("Rendering ", floor(height/hd) + 1, " layers"));

  for (i = [0:height/hd]) {
    translate([0, 0, i*hd])
    linear_extrude(hd)
    oval_outline(straight, radius, dbottom + i * delta);
  }
}

for (xy = sizes) {
  oval(sizes[0].x - sizes[0].y, sizes[0].y/2);
}