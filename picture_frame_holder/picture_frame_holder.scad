width = 15;
base = [10, 100];
support = 100;
thick = 2.5;
angle = 75;

offset = sin(90-angle)/sin(angle) * support;

translate([0, -base.x-thick, 0])
cube([width, base.x, thick]);

translate([0, -thick, 0])
cube([width, thick, support]);

translate([0, 0, offset])
cube([width, support, thick]);

hull () {
  inf = 0.01;
  cube([width, inf, thick]);

  translate([0, support, offset])
  cube([width, inf, thick]);
}