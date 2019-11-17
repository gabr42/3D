use <../../lib/curves.scad>
use <../../lib/mesh.solids.scad>

radius = 5;
angle = 45;

polygon(make_teardrop(radius, angle, center_at_point = true));