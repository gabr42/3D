include <../../../lib/helpers.math.scad>

dim = [40, 6, 39];
offset = 6; 
offset_z = 4;
thick_connector = 5;
overlap = 1;

module do_chamfer (offs) {
  if (offset == 0) {
    children();
  } else {
    offset(delta = offs, chamfer = true)
    offset(delta = -offs)
    children();
  }
}

module vert (chamfer) {
  rotate(90, [1,0,0])
  linear_extrude(dim.y)
  do_chamfer(chamfer ? 2 : 0)
  square([dim.x, dim.z]);
}

module connector () {
  rotate(-90, [0, 1, 0])
  linear_extrude(thick_connector)
  polygon([
    [0,0], 
    [0, dim.z - 2 * offset + overlap],
    [dim.z - 2 * offset + overlap, 0]
  ]);
}

difference () {
  union () {
    translate([0, dim.y, offset_z])
    vert(true);
  
    vert(false);
  }
  
  translate([-1, -1, -1])
  cube([dim.x + 2, 2, offset_z + 2]);

  hole = 2.5;
  dhole = [24, 0, 24];

  #for (x = [0:1])
    for (z = [0:1]) {
      translate([(dim.x - dhole.x)/2 + dhole.x * x, 0,
                 (dim.z - dhole.z)/2 + dhole.z * z])
      translate([0, 2, 0])
      rotate(90, [1,0,0])
      union () {    
        linear_extrude(dim.y * 2)
        circle(d = hole, $fn=50);
      }
    }
  }