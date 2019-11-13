use <geometry.scad>
use <curves.scad>
use <mesh.scad>

// Makes a polyhedron out of a mesh.

module mesh_polyhedron(mesh, closed = false) {
  polyhedron(mesh, make_band_faces(mesh, closed));
}   
   
// mesh_polyhedron(make_polygon_mesh(20, 7, 5, 3));

// renders a band sinusoidally oscillating along y and z axes

module sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  wsin = make_band_points(
           wave_points(length, yheight, zheight, num_waves, offset, offset + 90),
           ythick, zthick);
  mesh_polyhedron(wsin);  
}    

// tester for sinus_spiral()

module test_sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  color("red")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset);
  
  color("green")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset + 180);
}

//test_sinus_spiral(80, 10, 5, 5, 5, 2, $fn=50);

// renders a band based on segment_line()

module slab(length, dy, dz) {
  mesh_polyhedron(make_band_points(segment_line([0, 0, 0], [length, 0, 0]), dy, dz));
}