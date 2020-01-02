use <../lib/helpers.math.scad>
use <../lib/helpers.lists.scad>
use <../lib/geometry.scad>
use <../lib/geometry.manipulators.scad>
use <../lib/mesh.solids.scad>
use <../lib/curves.scad>

$fa = 1;
$fn = 300;

puck_d = 33;
puck_border = 3;
puck_raise = 1;
puck_thick = 1.2;
puck_r_fillet = 0.5;

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

stick_d = 40;
stick_d_center = 20;
stick_height = 50;
stick_border_height = 10;
stick_thick = 2;
stick_r_fillet = 1;
stick_r_fillet_bottom = 0.5;
stick_r_fillet_top = 7;

function stick_outline () =
  g_fillet(
    [[stick_r_fillet, [2, 3, 4, 5]],
     [stick_r_fillet_bottom, [6, 7]],
     [stick_r_fillet_top, [1, 8]]
    ],
    make_absolute_path([0, stick_height],
      [[stick_d_center/2, 0],
       [0, - (stick_height - stick_thick)],
       [(stick_d - stick_d_center)/2 - stick_thick, 0],
       [0, stick_border_height - stick_thick],
       [stick_thick, 0],
       [0, - stick_border_height],
       [- (stick_d - stick_d_center)/2 - stick_thick, 0],
       [0, stick_height - stick_thick],
       [- (stick_d_center/2 - stick_thick), 0]
      ]));

//visualize_curve(stick_outline(), 0.3);

module stick () {
  rotate_extrude(angle = 360)
  polygon(stick_outline());
}

//stick();
