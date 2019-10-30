include <../lib/helpers.scad>
use <../lib/curves.scad>
use <../lib/mesh.scad>
use <../lib/solids.scad>

$fn = 100;

r = 20;
yheight = 5;
zheight = 1;
ythick = 10;
zthick = 2;
num_waves = 5;
angle = 7;

length = 2 * pi * r * 1.2;

mesh1 = rotate_mesh(
          translate(
            make_band_points(
              wave_points(length, yheight, zheight, num_waves, 0, 90), ythick, zthick),
            [-length/2, -yheight, 0]),                                                                    
          angle);

mesh2 = rotate_mesh(
          translate(
            make_band_points(wave_points(length, yheight, zheight, num_waves, 180, 270), ythick, zthick),
            [-length/2, -yheight, 0]),                                                                    
          angle);
        
under = rotate_mesh(
          translate(
            make_band_points(segment_line([0, 0, -zthick/2], [length, 0, -zthick/2]), ythick, zthick),
            [-length/2, -yheight, 0]
          ),
          angle);

/** /
union() {
  color("red")
  mesh_polyhedron(mesh1);

  color("green")
  mesh_polyhedron(mesh2);
  
  color("blue")
  mesh_polyhedron(under);
}
/**/

/**/
module round_mesh(mesh) {
  ring = wrap_around_cylinder(mesh, r); 
  polyhedron(ring, make_band_faces(ring, ! angle));
}

color("green")
round_mesh(mesh1);

color("red")
round_mesh(mesh2);

color("blue")
round_mesh(under);
/**/
