width = 6;
radius = 30;
drop = 25;
cut = 2;
angle = 42;
connect = 0.5;

$fn = 50;

current_color = "ALL";

module multicolor(color) {
  if (current_color != "ALL" && current_color != color) {
    // ignore children
  } else {
    color(color)
    children();
  }
}


multicolor("white") {
  rotate(-angle)
  rotate_extrude(angle = 2 * angle)
  translate([radius, 0, 0])
  circle(r = width);

  difference() {
    rotate(180 - angle)
    rotate_extrude(angle = angle + 90)
    translate([radius, 0, 0])
    circle(r = width);

    translate([0, - radius - width, - width - 1])
    rotate(90)
    cube([radius + width, cut + width, 2 * width + 2]);
  }
}

multicolor("orange") {
  
}

color([0.7, 0.7, 0.7])
translate([radius*2.5, 0, 0]) {
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
}