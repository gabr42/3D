size = [50, 14, 5];
holes = [[5, 7.5], [45, 7.5], [25.5, 5]];
m = 4;

difference () {
  cube(size);
  
  for (h = holes) {
    translate(concat(h, [-1]))
    cylinder(size.z + 2, m/2, m/2, $fn = 20);
  }
}