rect_big = [7.7, 8.4, 2.5];
rect_small = [3.2, 4.8, 2.6];
connect = [7.7, 40, 5];
dist_rect = 25;

module lock () {
  color("red")
  cube(rect_big);

  color("green")
  translate([(rect_big.x - rect_small.x)/2, (rect_big.y - rect_small.y)/2, rect_big.z])
  cube(rect_small);
}

lock();

translate([0, dist_rect, 0])
lock();

translate([- (connect.x - rect_big.x)/2, (connect.y - (dist_rect + rect_small.y))/2 - rect_big.y, rect_big.z + rect_small.z])
cube(connect);