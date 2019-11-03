use <../lib/solids.scad>

width = 4;
radius = 20;
drop = 15;
cut = 2;
angle = 42;
connect = 0.5;

$fn = 50;

current_color = "white";

module multicolor(color) {
  if (current_color != "ALL" && current_color != color) {
    // ignore children
  } else {
    color(color)
    children();
  }
}


multicolor("white") {
  torus_segment(radius, width, -angle, angle);
  
  difference () {
    torus_segment(radius, width, 90 + angle, 270);

    translate([1, -radius + 1, 0])
    cube(2*width + 2, center = true);
  }
}

multicolor("orange") {
  difference () {
    torus_segment(radius, width, -angle, - 90 - 20);
    
    translate([- 2*width - 1, -radius + 1, 0])
    cube(2*width + 2, center = true);
  }
  
  torus_segment(radius, width, angle, 90 + angle);
  
  translate([0, - radius + drop, 0])
  rotate(90, [1, 0, 0])
  linear_extrude(height = drop)
  circle(r = width);
  
  translate([0, radius - drop, 0])
  rotate(-90, [1, 0, 0])
  linear_extrude(height = drop)
  circle(r = width);
}

