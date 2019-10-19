ro = 30;  // outer radius
ri = 20;  // inner radius
ho = 25;  // height of bottom part
h  = 40;  // full height
c1 = 2;   // rounded corners

hole       = [16, 16, 20]; // cut-out
lock_hole  = [8, 3, 20];   // space for lock mechanism
lockerw    = 1;   // depth of the locker tab
locker_cut = 0.5; // depth of the locker cut

tooth_side = 2;
tooth_under = 2; // distance from top of the tooth to top of the model

precision1 = 30;
precisiono = 200;

module outline() {
  union () {

    difference() {
      polygon (
        [ [0,0], [ro-c1,0], [ro,c1], [ro,ho-c1], [ro-c1,ho], [ri+c1,ho], 
          [ri, ho+c1], [ri, h-c1], [ri-c1,h], [0,h]],
        [[0,1,2,3,4,5,6,7,8,9]]
      );
      
      translate([ri+c1, ho+c1])
        color("green")
        circle(c1, $fn=precision1);
    };
    
    translate([ro-c1, c1])
      color("red")
      circle(c1, $fn=precision1);  
    
    translate([ro-c1, ho-c1])
      color("red")
      circle(c1, $fn=precision1);  
    
    translate([ri-c1, h-c1])
      color("red")
      circle(c1, $fn=precision1);  
  }
}

module solid() {
  rotate_extrude(angle=360, convexity=10, $fn=precisiono) 
    outline();  
}

module hole() {
  translate([0, 0, h - (hole.z / 2) + 0.001])
  color("blue")
  cube(hole, center = true);
}

module lock_hole() {
  cut = [locker_cut, lockerw + lock_hole.y, lock_hole.z];

  translate([- (lock_hole.x + cut.x) / 2, (lockerw + hole.y + lock_hole.y) / 2, h - (cut.z / 2) + 0.001])
  color("blue")
  cube(cut, center = true);
  
  translate([(lock_hole.x + cut.x) / 2, (lockerw + hole.y + lock_hole.y) / 2, h - (cut.z / 2) + 0.001])
  color("blue")
  cube(cut, center = true);
  
  translate([0, (hole.y + lock_hole.y) / 2 + lockerw,  h - (lock_hole.z / 2) + 0.001])
  color("blue")
  cube(lock_hole, center = true);
}

module tooth() {
  translate([lock_hole.x / 2, (hole.y - tooth_side) / 2, h - tooth_side - tooth_under])
  rotate([90, 0, -90])
  linear_extrude(lock_hole.x)
  circle(tooth_side, $fn=3);
}

union() {
  difference() {
    solid();
    
    hole();
    lock_hole();
  };
  
  tooth();
}