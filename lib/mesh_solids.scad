use <curves.scad>;
use <mesh.scad>;

// Makes a polyhedron out of a mesh.

module mesh_polyhedron(mesh, closed = false) {
  polyhedron(mesh, make_band_faces(mesh, closed));
}

// Generates a polygon offset in y and z direction.

function make_polygon_mesh(r, numSides, ywidth, zwidth) =
  let (p1o = unit_polygon(numSides) * r)
  let (p1 = concat(p1o, [p1o[0]]))
  let (p2 = scale(p1, (r - ywidth)/r))
  concat(p2,
         p1,
         translate(p2, [0, 0, zwidth]),
         translate(p1, [0, 0, zwidth]));
   
   
//mesh_polyhedron(make_polygon_mesh(20, 7, 5, 3));
