include <../lib/helpers.scad>
use <../lib/curves.scad>

r = 20;
yheight = 5;
zheight = 1;
ythick = 10;
zthick = 2;
num_waves = 5;

length = 2 * pi * r;

/*
difference() {
  test_sinus_spiral(length, 5, 1, 10, 2, 4, offset=90, $fn=50);
  
  translate([0, -5, -1.5])
  cube([length, 20, 2]);
}
                                        
translate([0, -5, -1.5])
cube([length, 20, 2]);
*/

function curve_points(offset) = wave_points_3d(length, yheight, zheight, num_waves, offset, offset + 90);

module round_wave(offset) {
  curve_pt = curve_points(offset);
  curve = make_band_points(curve_pt, ythick, zthick);
  ring = wrap_around_cylinder(curve, r); 
  polyhedron(ring, make_band_faces(curve_pt));
}

$fn = 200;

color("green")
round_wave(0);

color("red")
round_wave(180);

