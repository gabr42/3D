use <../lib/helpers.math.scad>
use <../lib/helpers.lists.scad>
use <../lib/geometry.scad>
use <../lib/geometry.manipulators.scad>
use <../lib/mesh.solids.scad>
use <../lib/curves.scad>

puck_d = 33;
puck_border = 3;
puck_raise = 1;
puck_thick = 1.2;
puck_r_fillet = 0.5;

$fa = 3;
$fn = 100;

function puck_outline () =
  g_fillet(puck_r_fillet,
    make_absolute_path([0, 0],
      [[puck_d/2, 0], 
       [0, puck_thick + puck_raise], 
       [- puck_border, 0], 
       [0, - puck_raise], 
       [- (puck_d/2 - puck_border), 0]]));

module puck () {
  rotate_extrude(angle = 360)
  polygon(puck_outline());
}

puck();
