use <../lib/helpers.lists.scad>
use <../lib/geometry.manipulators.scad>
use <../lib/curves.scad>
use <../lib/mesh.solids.scad>
use <../lib/solids.scad>

$fn = 30;
$fa = 15;
$fs = 10;

rotate(10, [0,1,0])
multi_twister($fs,
  translate = [0, 0, 40],
  angles = [55, 90, 90],
  initial_angles = [-10, 0, 0],
  origins = [[0,0], [0,0], [3, 5]],
  vs = [[0,1,0], [0,0,1], [0,0,1]],
  scale = [0.5, 0.25])
scale([1, 0.5])
circle(5, $fn=4);
