include <heatbed-cable-cover.scad> // from original Prusa parts

module support_out () {
  union () {
    cylinder(d=9+2, h=10, $fn=49);
    
    translate([0, 0, 10])
    cylinder(d1=9+2, d2=8+2, h=3, $fn=49);
    
    translate([0, 0, 13])
    cylinder(d=8+2, h=5, $fn=49);
  }
}

difference () {
  translate([0, 36, -3])
  rotate(-90, [1,0,0])
  intersection () {
    union () {
      difference () {
        support_out();
        
        translate([0, 0, -1])
        union () {
          cylinder(d=9, h=11, $fn=49);
          
          translate([0, 0, 11])
          cylinder(d1=9, d2=8, h=3, $fn=49);

          translate([0, 0, 14])
          cylinder(d=8, h=6, $fn=49);
        }
      }
      
      difference () {
        translate([-(9+2)/2, 0, 0])
        difference () {
          cube([9+2, 6, 17.99]);

          for(dx = [0:1])
          for(dy = [0:1])
          translate([dx * (9+2), dy * 6, (1 - dy) * 10])
          cylinder(d=1.5, h=19, $fn=4);
        }
        
        support_out();
      }
    }
      
    translate([-10, -2, 0])
    cube([20, 20, 40]);
  }
  
  for (s=[-1:2:1])
  translate([s * (9+2)/2, 36 + 18, -10])
  cylinder(d=1.5, h=20, $fn=4);
  
  for (i=[0:1])
  translate([-10, 36 + 18, -1 - 8*i])
  rotate([0, 90, 0])
  cylinder(d=1.5, h=20, $fn=4);
  
  translate([0, 36 + 17 + 0.125, -3])
  rotate([-90, 0, 0])
  rotate_extrude(angle=360, $fn=49)
  translate([5, 0, 0])
  difference () {
    translate([-1, 0])
    square([1, 1]);
    circle(d=2, $fn=21);
  }  
}