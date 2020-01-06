use <../lib/solids.scad>

rect_big = [7.5, 8.4, 2.5];
rect_small = [2.9, 4.8, 2.6];
connect = [7.5, 40, 5];
dist_rect = 25;

$fn = 50;

module lock () {
  color("red")
  rcube(rect_big, 1);

  color("green")
  translate([(rect_big.x - rect_small.x)/2, (rect_big.y - rect_small.y)/2, rect_big.z])
  rcube(rect_small, 0.5);
}

lock();

translate([0, dist_rect, 0])
lock();

translate([- (connect.x - rect_big.x)/2, (connect.y - (dist_rect + rect_small.y))/2 - rect_big.y, rect_big.z + rect_small.z])
rcube(connect, 1);