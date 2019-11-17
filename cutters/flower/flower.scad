use <../../lib/curves.scad>
use <../../lib/mesh.solids.scad>

use <../../lib/helpers.lists.scad>

radius = 5;
rcircle = 4;
angle = 60;
num_leaves = 5;
dbottom = 0.5;
dtop = 2.5;
height = 13;

sizes = [57, 42, 35];

$fn = 50;

module flower_leaves (radius, angle, num_leaves) {
  for (i = [0:num_leaves - 1]) {
    rotate(360/num_leaves * i)
    polygon(make_teardrop(radius, angle, center_at_point = true));
  }
}

module flower_2D (radius, angle, num_leaves, rcircle) {
  difference () {
    offset(delta=dbottom)
    flower_leaves(radius, angle, num_leaves);
    
    flower_leaves(radius, angle, num_leaves);
    circle(rcircle);
  }

  difference () {
    offset(delta=dbottom)
    circle(rcircle);
    
    circle(rcircle);
    flower_leaves(radius, angle, num_leaves);
  }
}

module flower (radius, angle, num_leaves, rcircle) {
  translate([0, 0, height])
  rotate(180, [1,0,0])
  for (s = [100:105]) {
    linear_extrude(height, scale = s/100)
    flower_2D(radius, angle, num_leaves, rcircle);
  }
}

echo((cos(360/num_leaves/2) + 1) *  (radius / sin (angle/2) + radius));

// d = (cos(360/num_leaves/2) + 1) *  (radius / sin (angle/2) + radius);
// D = C * (r/s + r)
// D/C = r/s + r
// D/C = r(1/s + 1)
// D/C = r((1+s)/s)
// D/C*s/(1+s) = r

for (i = [0:len(sizes)-1]) {
  r = sizes[i] / (cos(360/num_leaves/2) + 1) * sin(angle/2) / (sin(angle/2) + 1);  
  
  translate([1.1 * sum_list(slice(sizes, [0:1:i-1])), 0, 0])
  flower(r, angle, num_leaves, rcircle);
}
