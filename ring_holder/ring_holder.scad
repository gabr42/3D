use <../lib/geometry.scad>
use <../lib/curves.scad>
use <../lib/mesh.scad>
use <../lib/mesh.solids.scad>

height = 70;
radius = 20;
step = 7;
ring_height = height - 2*step;
numsides = 7;
xwidth = 1;
ywidth = 1;
zwidth = 1;

module rings () {
  for (i = [0:step:ring_height]) {
    mesh_polyhedron(
      translate(
        make_polyhedron_mesh(radius * (height - i)/height, numsides, ywidth, zwidth),
        [0, 0, i])
    );
  }
}

module tent () {
  b = translate(make_segment_line([0,0,0], [0,0,height], $fn=4), [-xwidth/2, -ywidth/2, 0]);
  mesh = concat(b, 
                translate(b, [xwidth, 0, 0]),
                translate(b, [0, ywidth, 0]),
                translate(b, [xwidth, ywidth, 0]));
  b1 = /*twist_mesh(*/mesh/*, [0,0,0], [0,0,height], 360)*/;
  for (pt = [0:1:numsides-1]) {
    v = point_on_unit_circle(360/numsides*pt) * (radius - xwidth/2);
    c = zshear_mesh(b1, [0, 0, height], [0, 0, 0], [0, 0, height], [v.x, v.y, 0]);
    mesh_polyhedron(c);
  }
}

// rings();
tent();