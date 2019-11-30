use <../external/fibsphere/files/fibonacci_sphere.scad>

d1 = 19;
d2 = 26.6;
d = 6;
dh = 7.5;
wall = 3;
dball = 25;
ball_out = 8.5;
over_x = 3;
over_z = 3;

$fn = 50;
inf = 0.1;

r1 = d1/2;
r2 = d2/2;
rh = (r2 - r1) / d * dh + r1;

module funnel () {
  difference () {
    cylinder(dh, r1 + wall, rh + wall);

    translate([0, 0, -inf])
    cylinder(dh + 2*inf, r1, rh);
  }

  translate([0, 0, dh])
  cylinder(wall, rh + wall, rh + wall);
}

module ball () {
  translate([0, 0, - ball_out])
  difference () {
    fibonacci_sphere(dball/2 + wall, 101);

    fibonacci_sphere(dball/2, 101);
  }
}

module magnet_holder () {
  translate([-wall, 0, 0])
  rotate(-90, [0,1,0])
  translate([-over_x, 0, - dh - wall])
  difference () {
    union () {
        funnel();
        ball();
    }

    translate([over_x, - dball, - 2*dball + dh])
    cube([2*dball, 2*dball, 2*dball]);

    cylinder(dh + 2*inf, r1, rh);

    translate([-dball, -dball, -2*dball - ball_out - over_z])
    cube([2*dball, 2*dball, 2*dball]);
  }
}

magnet_holder();
