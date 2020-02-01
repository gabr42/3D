include <../lib/helpers.math.scad>
use <../lib/solids.scad>
use <wuteku_holder.scad>

thick = 3;
support_block = [30, 50, 27];
connect_block = [33, 27];
connect_overhang = 10;
connect_vert = [18, 100];
r_connect = 4;

module plate (x, y, support_space = 10, thickness) {
  thickness = is_undef(thickness) ? thick : thickness;
  slab([x, y, thickness], hollow = is_undef(support_space) ? undef : "D", support_thick = 1.5, support_space = support_space, support_angle = 60);
}

module inset () {
  M = [ [ 1  , -0.04  , 0  , 0   ],
        [ 0  , 1  , 0  , 0   ], 
        [ 0  , 0  , 1  , 0   ],
        [ 0  , 0  , 0  , 1   ] ] ;
  multmatrix(M) 
  union () {
    plate(support_block.x, support_block.y);

    translate([0, 0, support_block.z - thick])
    plate(support_block.x, support_block.y);

    translate([support_block.x, 0, 0])
    rotate(-90, [0,1,0])
    plate(support_block.z, support_block.y);
  }
}

module connect () {
  translate([support_block.x - connect_overhang, thick, 0])
  rotate(90, [1, 0, 0])
  plate(connect_block.x - connect_vert.x, connect_block.y, undef);
}

module vertical () {
  translate([support_block.x + connect_block.x - connect_overhang - connect_vert.x, thick, 0])
  rotate(90, [1, 0, 0])
  plate(connect_vert.x, connect_vert.y + connect_block.y - connect_vert.x, 13);
}

module holder_adapter () {
  translate([support_block.x + connect_block.x - connect_overhang - connect_vert.x, thick, connect_vert.y + connect_block.y - connect_vert.x])
  rotate(90, [1, 0, 0])
  difference () {
    plate(connect_vert.x, connect_vert.x, support_space = undef);
    
    translate([connect_vert.x /2, connect_vert.x /2, , -inf])
    cylinder(thick + 2 * inf, r_connect, r_connect);
   
    translate([connect_vert.x/2 - r_connect, connect_vert.x / 2, -inf])
    plate(r_connect * 2, connect_vert.x / 2 + inf, thickness = thick + 2 * inf);
  }
}

module screw_hole () {
  translate([support_block.x + connect_block.x - connect_overhang - connect_vert.x, thick, connect_vert.y + connect_block.y - 2 * connect_vert.x])
  rotate(90, [1, 0, 0])
  plate(connect_vert.x, connect_vert.x, support_space = undef);
}

module part1 () {
  color("red")
  inset();

  color("green")
  connect();

  color("blue")
  vertical();

  color("magenta")
  holder_adapter();
  
  color("gold")
  screw_hole();
}

slack = 0.1;

module part2 () {
  translate([- 2*thick - 2*slack + wuteku_offset().x, 0, 0])
  rotate(90, [0, 1, 0])
  union () {
    translate([0, 0, thick])
    cylinder(thick + slack * 3, r_connect - slack/2, r_connect - slack/2);

    cylinder(thick, connect_vert.x/2, connect_vert.x/2);
  }

  color("magenta")
  translate([0, 0, - wuteku_offset().z - wuteku_dimensions().z/2])
  magnet_holder();
}

color("green")
part1();

//translate([support_block.x + connect_block.x - connect_overhang - connect_vert.x/2, -thick - slack, connect_vert.y + connect_block.y - connect_vert.x/2 + slack])
translate([-50, 0, 0])
rotate(-90)
color("red")
part2();
