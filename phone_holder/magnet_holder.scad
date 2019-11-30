use <../external/fibsphere/files/fibonacci_sphere.scad>

d1 = 19;
d2 = 26.6;
d = 6;
dh = 7;
wall = 2;
dball = 25;
ball_out = 8.5;
over_x = 2;
over_z = 1;

$fn = 50;
inf = 0.1;

r1 = d1/2;
r2 = d2/2;
rh = (r2 - r1) / d * dh + r1;

module funnel () {
  difference () {
    cylinder(dh, r1 + wall, r2 + wall);

    translate([0, 0, -inf])
    cylinder(dh + 2*inf, r1, r2);
  }
}

module ball () {
  translate([0, 0, - ball_out])
  difference () {
    fibonacci_sphere(dball/2 + wall, 101);

    fibonacci_sphere(dball/2, 101);
  }
}

difference () {
  union () {
    funnel();
    ball();
  }

  translate([over_x, -dball, -dball])
  cube([2*dball, 2*dball, 2*dball]);

  cylinder(dh + 2*inf, r1, r2);

  translate([-dball, -dball, -2*dball - ball_out - over_z])
  cube([2*dball, 2*dball, 2*dball]);
}