include <../lib/helpers.scad>
use <../lib/curves.scad>
use <../lib/mesh.scad>

r = 20;
yheight = 5;
zheight = 1;
ythick = 10;
zthick = 2;
num_waves = 5;
angle = 10;

length = 2 * pi * r * 1.3;

mesh1 = rotate_mesh(
        translate(
          make_band_points(
            wave_points(length, yheight, zheight, num_waves, 0, 90, $fn=50), ythick, zthick),
          [-length/2, -yheight, 0]),                                                                    
        angle);

mesh2 = rotate_mesh(
        translate(
          make_band_points(wave_points(length, yheight, zheight, num_waves, 180, 270, $fn=50), ythick, zthick),
          [-length/2, -yheight, 0]),                                                                    
        angle);

/** /
difference() {
  union() {
    color("red")
    polyhedron(mesh1, make_band_faces(mesh1));
  
    color("green")
    polyhedron(mesh2, make_band_faces(mesh2));
  }
}
/**/

/**/
module round_wave(mesh) {
  ring = wrap_around_cylinder(mesh, r); 
  polyhedron(ring, make_band_faces(ring, ! angle));
}

$fn = 50;

color("green")
round_wave(mesh1);

color("red")
round_wave(mesh2);

