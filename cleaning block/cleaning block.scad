size = 17.5;
height = 1.5;
wall = 1.2;
air = 0.6;


rotate(180, [1, 0, 0])
difference () {
  cube([size, size, height]);
 
  size_cut = (size - 3*wall) / 2;
  
  for (i = [0:1])
  for (j = [0:1])
    translate([wall + (size_cut + wall) * i, wall + (size_cut + wall) * j, height - air + 0.01])
    cube([size_cut, size_cut, air + 0.01]);
}