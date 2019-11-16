use <../../lib/geometry.manipulators.scad>

width = 50;
height = 100;
holes = [[10,10], [10, 90], [40, 10], [40, 90]];
screws = 3;
thick = 5;
delta = [40, -35, -15] + [0, 2 * thick, 0];
connection = [8, 50];

inf = 0.01;

module make_holes () {
  for (pt = holes) {
    translate([pt.x, -inf, pt.y])
    rotate(-90, [1, 0, 0])
    cylinder(h = thick + 2 * inf, r = screws/2, $fn = 50);
  }
}

module base_plate () {
  difference () {
    cube([width, thick, height]);
    make_holes();
  }
}

module connection2 () {
  c1 = [(width - connection.x) / 2, 0, (height - connection.y) / 2];
  r1 = [c1, c1 + [connection.x, 0, 0], c1 + [0, 0, connection.y], c1 + [connection.x, 0, connection.y]];
  r2 = g_translate(delta + [0, thick, 0], r1);

  //23
  //01

  //67
  //45
  polyhedron(
    points = concat(r1, r2),
    faces = [[0,1,3,2], [4,6,7,5], [2,6,4,0], [7,3,1,5], [2,3,7,6], [4,5,1,0]]
  );
}

base_plate();

translate(delta)
base_plate();

connection2();
