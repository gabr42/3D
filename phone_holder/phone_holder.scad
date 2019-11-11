use <../lib/helpers.lists.scad>
use <../lib/curves.scad>

l = make_logistic_curve(-20, 20, 4, 4, $fn=50);

polygon(concat(l, translate(reverse(l), [0, -1])));