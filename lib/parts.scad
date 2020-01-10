include <helpers.math.scad>

// Draws 2D male/female dovetail, suitable for extrusion.

module dovetail(size, male, slack=0.5) {
  if (male)
    offset(slack)
    offset(-slack)
    translate([-size.x/2 + slack, -size.y + slack])
    difference () {
      square(size - [2*slack, slack]);
      
      rotate(45)
      square([2*size.y, 2*size.y]);

      translate([size.x - 2*slack, 0, 0])
      rotate(45)
      square([2*size.y, 2*size.y]);
    }
  else
    let (diag = sqrt(2) * size.y)
    difference () {
      union () {
        difference () {
          translate([-size.x/2, -size.y])
          square([size.x, size.y]);
         
          translate([- (size.x - diag)/2, -4*slack + 0.01])
          square([size.x - diag, 4*slack]);
        }
        
        translate([- (size.x/2  - diag/2 + 0.5*slack), -1.2*slack])
        circle(sqrt(2) * slack);
        
        translate([size.x/2  - diag/2 + 0.5*slack, -1.2*slack])
        circle(sqrt(2) * slack);
      }
      
      translate([-size.x/2, 0])
      square(size);

      dovetail([size.x + 2*slack, size.y], true);
    }
}