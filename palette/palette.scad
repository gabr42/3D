palette(wall= 1, size = 30, hei = 10);

module palette(wall, size, hei) {
  cell = (size - 4*wall)/3;

  difference () {
    cube([size, size, hei]);

    translate([wall, wall, wall]) {
      for (x = [1:3])
      for (y = [1:2:3])
        translate([(x-1) * (cell + wall), (y-1) * (cell + wall), 0])
        cube([cell, cell, hei]);
      
      translate([0, cell + wall, 0])
      cube([size - 2*wall, cell, hei]);
    }
  }
}