use <../../lib/curves.scad>
use <../../lib/helpers.lists.scad>
include <../cutters.scad>

rcircle_pct = 0.13;
tcircle_pct = 0.2;
angle = 60;
num_leaves = 5;


// cutter_release = true;
// cutter_verbose = true;

sizes = [35]; // [56, 49, 42, 35];

$fn = 50;
$fa = 2;

module flower_leaves (radius, angle, num_leaves) {
  for (i = [0:num_leaves - 1]) {
    rotate(360/num_leaves * i)
    polygon(make_teardrop(radius, angle, center_at_point = true));
  }
}

module flower_rays (radius, num_leaves, rcircle, d) {
  for (i = [0:num_leaves]) {
    rotate(360 / num_leaves * i)
    translate([rcircle + d, -d/2, -1])
    cube([radius, d, cutter_height + 2]);
  }
}

module flower (radius, angle, num_leaves, rcircle, tcircle) {
  difference () {
    cutter_render_wall_difference () {
      flower_leaves(radius, angle, num_leaves);
      circle(rcircle);
    }

    flower_rays(radius * 4, num_leaves, rcircle, 1.5 * cutter_dtop);
  }

  linear_extrude(2)
  circle(tcircle);
}

// d = (cos(360/num_leaves/2) + 1) *  (radius / sin (angle/2) + radius);
// D = C * (r/s + r)
// D/C = r/s + r
// D/C = r(1/s + 1)
// D/C = r((1+s)/s)
// D/C*s/(1+s) = r

for (i = [0:len(sizes)-1]) {
  r = sizes[i] / (cos(360/num_leaves/2) + 1) * sin(angle/2) / (sin(angle/2) + 1);  
  
  translate([1.1 * sum_list(slice(sizes, [0:1:i-1])), 0, 0])
  flower(r, angle, num_leaves, rcircle_pct * sizes[i], tcircle_pct * sizes[i]);
}