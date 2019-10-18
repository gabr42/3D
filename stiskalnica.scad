ro = 25;
ri = 13;
ho = 25;
h = 40;
c1 = 3;
hole = [16, 16, 20];  
precision1 = 30;
precisiono = 200;

difference() {

/**/
rotate_extrude(angle=360, convexity=10, $fn=precisiono) 
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
  
/**/
  
  translate([0, 0, h - (hole.z / 2)])
  color("blue")
  cube(hole, center = true);
}