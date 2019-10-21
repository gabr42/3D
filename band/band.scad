use <../lib/curves.scad>

length = 120;

difference() {
  test_sinus_spiral(length, 5, 1, 10, 2, 4, offset=90, $fn=50);
  
  translate([0, -5, -1.5])
  cube([length, 20, 2]);
}

translate([0, -5, -1.5])
cube([length, 20, 2]);