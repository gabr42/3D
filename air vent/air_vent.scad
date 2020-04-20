use <solids.scad> //  https://github.com/gabr42/3D/blob/master/lib/solids.scad
use <line2d.scad> // https://github.com/JustinSDK/dotSCAD/blob/master/src/line2d.scad

d_out = 50;
d_in = 40;
h_out = 3;

vert_offs = d_in/5.5;

d2_out = 44.5;
d2_in = 42;
h_in = 10;

chamfer = h_out/2;

bar_w = 1.6;
bar_h = 3;
supp_h = 5;

lock = 1;

$fn = $preview ? 25 : 100;

difference () {
  union () {
    cylinder(d = d_out, h = h_out - chamfer);
    
    translate([0, 0, h_out - chamfer])
    cylinder(d1 = d_out, d2 = d_out - 2 * chamfer, h = chamfer);
  }

  translate([0, 0, -0.01])
  cylinder(d = d_in, h = h_out + 0.02);
}

translate([0, 0, -h_in])
difference () {
  union () {
    translate([0, 0, chamfer])
    cylinder(d = d2_out, h = h_in - chamfer);

    cylinder(d1 = d2_out - chamfer, d2 = d2_out, h = chamfer);
  }

  translate([0, 0, -0.01])
  cylinder(d = d2_in, h = h_in + 0.02);
}

intersection () {
  union () {
    for (sign = [-1:2:1]) {
      translate([0, 0, -supp_h + h_out])
      linear_extrude(supp_h)
      line2d([sign * vert_offs, - d_in/2], [sign * vert_offs, d_in/2], bar_w);

      for (dy = [bar_w:bar_w*2:d_in])
      linear_extrude(bar_h)
      line2d([-d_in, sign*dy], [d_in, sign*dy], bar_w);
    }
  }

  translate([0, 0, -25])
  cylinder(d = d_in + 1, h = 50);
}

for (a=[0:60:359])
  rotate(a)
  translate([d2_out/2 - 0.01, -lock/2, -3*h_in/4+0.01])
  rotate(-90, [0, 0, 1])
  rotate(-90, [0, 1, 0])
  angle_trim_cube([3*h_in/4, lock, lock], angle_start = 45);
