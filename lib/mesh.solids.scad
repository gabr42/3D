use <geometry.scad>
use <geometry.manipulators.scad>
use <curves.scad>
use <mesh.scad>

// Makes a polyhedron out of a mesh.

module mesh_polyhedron(mesh, closed = false) {
  polyhedron(mesh, make_band_faces(mesh, closed));
}   
   
//mesh_polyhedron(make_polygon_mesh(20, 7, 5, 3));

// renders a band sinusoidally oscillating along y and z axes

module sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  wsin = make_band_points(
           make_wave(length, yheight, zheight, num_waves, offset, offset + 90),
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

//test_sinus_spiral(80, 5, 1, 10, 3, 2, $fn=50);
//translate([40, 5, 0])
//cube([80, 20, 2], center = true);

// renders a band based on segment_line()

module slab(length, dy, dz) {
  mesh_polyhedron(make_band_points(segment_line([0, 0, 0], [length, 0, 0]), dy, dz));
}

// Draws a very thin curve in Preview only.

module visualize_curve (curve, width = 0.1) {
  if ($preview) {
    w2 = width/2;
    color("red", alpha=0.2)
    mesh_polyhedron(
      make_curve_replicas([[-w2, -w2, -w2], [-w2, w2, w2], [w2, -w2, w2], [w2, w2, -w2]], 
        make_3D(curve)));
  }
}