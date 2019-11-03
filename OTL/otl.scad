width = 6;
radius = 30;
drop = 25;
cut = 2;
angle = 42;
connect = 0.5;

$fn = 50;

difference () {
  rotate_extrude(angle=360)
  translate([radius, 0, 0])
  circle(r = width);

  rotate(-angle)
  cube([2*(radius + width) + 2, cut, 2 * width + 2], center = true);

  rotate(angle)
  translate([(radius + width)/2, 0, 0])
  cube([radius + width + 2, cut, 2 * width + 2], center = true);

  translate([-width - cut/2, -radius])
  rotate(90)
  cube([radius + width + 2, cut, 2 * width + 2], center = true);
}

translate([0, - radius + drop, 0])
rotate(90, [1, 0, 0])
linear_extrude(height = drop)
circle(r = width);

translate([0, radius - drop, 0])
rotate(-90, [1, 0, 0])
linear_extrude(height = drop)
circle(r = width);

rotate_extrude(angle=360)
translate([radius, 0, 0])
circle(r = connect);