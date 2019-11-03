use <curves.scad>
use <mesh.scad>

module sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  wsin = make_band_points(
           wave_points(length, yheight, zheight, num_waves, offset, offset + 90),
           ythick, zthick);
  polyhedron(wsin, make_band_faces(wsin));  
}    

module test_sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  color("red")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset);
  
  color("green")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset + 180);
}

//test_sinus_spiral(80, 10, 5, 5, 5, 2, $fn=50);

module slab(length, dy, dz) {
  points = make_band_points(segment_line([0, 0, 0], [length, 0, 0]), dy, dz);
  polyhedron(points, make_band_faces(points));
}

module mesh_polyhedron(mesh) {
  polyhedron(mesh, make_band_faces(mesh));
}

module torus_segment(r1, r2, angle_from=0, angle_to=360) {
  rotate(angle_from)
  rotate_extrude(angle = (angle_to - angle_from))
  translate([r1, 0, 0])
  circle(r = r2);
}