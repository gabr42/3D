use <../lib/solids.scad>

base = [60, 60, 10];
hole_1 = [25, 60, 20];
hole_2 = [25, 40, 40];
screws = [37.5, 37.5, 8];
d_hole = 13.5;
d_screw = 4.5;
d_screw_head = 10;
h_transition = 2.5;

$fn = 50;

module base_mount () {
  hull_chain () {
    rcube(base, 1);

    translate([(base.x - hole_1.x)/2, 0, 0])
    rcube(hole_1, 1);

    translate([(base.x - hole_2.x)/2, (base.y - hole_2.y)/2, 0])
    rcube(hole_2, 1);
  }
}

module make_screw_hole (pos) {
  translate(pos) {
    translate([0, 0, screws.z + h_transition])
    cylinder(h = hole_2.z, d = d_screw_head);

    translate([0, 0, screws.z])
    cylinder(h = h_transition, d1 = d_screw, d2 = d_screw_head);

    translate([0, 0, -1])
    cylinder(h = hole_2.z, d = d_screw);
  }
}

difference () {
  base_mount();

  translate([base.x/2, 0, hole_1.z + (hole_2.z - hole_1.z)/2])
  rotate(-90, [1, 0, 0])
  cylinder(h = base.y, d = d_hole);

  for (dx=[0:1])
  for (dy=[0:1])
    make_screw_hole([(base.x - screws.x)/2 + dx * screws.x,
                     (base.y - screws.y)/2 + dy * screws.y]);
}
