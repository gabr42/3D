use <../../lib/curves.scad>
use <../../lib/mesh.solids.scad>
use <../../lib/helpers.lists.scad>

rcircle_pct = 0.13;
tcircle_pct = 0.2;
angle = 60;
num_leaves = 5;
dbottom = 0.4;
dtop = 2;
height = 13;
extra = 1;
delta = 0.05;

sizes = [35]; // [56, 49, 42, 35];

$fn = 50;
$fa = 2;

module flower_leaves (radius, angle, num_leaves) {
  for (i = [0:num_leaves - 1]) {
    rotate(360/num_leaves * i)
    polygon(make_teardrop(radius, angle, center_at_point = true));
  }
}

module flower_2D (radius, angle, num_leaves, rcircle, delta) {
  difference () {
    offset(delta=delta)
    flower_leaves(radius, angle, num_leaves);
    
    flower_leaves(radius, angle, num_leaves);
    circle(rcircle);
  }

  difference () {
    offset(delta=delta)
    circle(rcircle);
    
    circle(rcircle);
    flower_leaves(radius, angle, num_leaves);
  }
}

module flower_rays (radius, num_leaves, rcircle, d) {
  for (i = [0:num_leaves]) {
    rotate(360 / num_leaves * i)
    translate([rcircle + d, -d/2, -1])
    cube([radius, d, height + 2]);
  }
}

module flower (radius, angle, num_leaves, rcircle) {
  steps = floor((dtop - dbottom) / delta);
  hd = height/steps;

  translate([0, 0, height])
  rotate(180, [1, 0, 0])
  difference () {
    union () {
      for (i = [0:1:steps-1]) {
        translate([0, 0, i*hd])
        linear_extrude(hd)
        flower_2D(radius, angle, num_leaves, rcircle, dbottom + i * (dtop - dbottom) / (steps - 1));
      }
    }

    flower_rays(radius * 4, num_leaves, rcircle, 1.5 * dbottom);
  }
}

echo(str("Layer height: ", height/(floor((dtop - dbottom) / delta))));

// d = (cos(360/num_leaves/2) + 1) *  (radius / sin (angle/2) + radius);
// D = C * (r/s + r)
// D/C = r/s + r
// D/C = r(1/s + 1)
// D/C = r((1+s)/s)
// D/C*s/(1+s) = r

for (i = [0:len(sizes)-1]) {
  r = sizes[i] / (cos(360/num_leaves/2) + 1) * sin(angle/2) / (sin(angle/2) + 1);  
  
  translate([1.1 * sum_list(slice(sizes, [0:1:i-1])), 0, 0])
  union () {
    flower(r, angle, num_leaves, rcircle_pct * sizes[i]);
    
    linear_extrude(2)
    circle(tcircle_pct * sizes[i]);  
  }
}