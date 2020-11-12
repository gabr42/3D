object_shape = "cylinder";
object_size = 40;
object_height = 55;
object_wall = 2;
object_bottom = 6;

if (object_shape == "box") {
  difference () {
    cube([object_size, object_size, object_height], center = true);
    
    translate([0, 0, object_bottom])
    cube([object_size - 2*object_wall, object_size - 2*object_wall, object_height], center = true);
  }
}
else {
  difference () {
    cylinder(d = object_size, h = object_height, $fn = 360);

    translate([0, 0, object_bottom])
    cylinder(d = object_size - 2*object_wall, h = object_height, $fn = 360);
  }
}
