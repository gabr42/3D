use <external/fibsphere/files/fibonacci_sphere.scad>

difference () {
  fibonacci_sphere(15, 250);

  fibonacci_sphere(14.5, 250);

  translate([0, 0, -20])
  cube ([40, 40, 40], center = true);
}