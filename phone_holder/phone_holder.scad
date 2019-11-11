use <../lib/curves.scad>
use <../lib/mesh.scad>

l = logistic_curve(-20, 20, 4, 4, $fn=50);

polygon(concat(l, translate(reverse(l), [0, -1])));