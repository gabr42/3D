include <helpers.math.scad>
use <geometry.scad>

function dovetail_default_slack() = 0.5;

// Draws 2D male/female dovetail, suitable for extrusion.

module dovetail_2D(size, male, slack=undef, connect_y = undef) {
  slack = is_undef(slack) ? dovetail_default_slack() : slack;
  diag = sqrt(2) * size.y;
  if (male) 
    union () {
      offset(slack)
      offset(-slack)
      translate([-size.x/2 + slack, -size.y + slack])
      difference () {
        square(make_2D(size) - [2*slack, slack]);
        
        rotate(45)
        square([2*size.y, 2*size.y]);

        translate([size.x - 2*slack, 0, 0])
        rotate(45)
        square([2*size.y, 2*size.y]);
      }
      
      if (connect_y > 0)
        translate([-size.x/2+size.y, 0])
        square([size.x - 2*size.y, connect_y]);
    }
  else
    difference () {
      union () {
        difference () {
          translate([-size.x/2, -size.y])
          square([size.x, size.y]);
         
          translate([- (size.x - diag)/2, -4*slack + 0.01])
          square([size.x - diag, 4*slack]);
        }
        
        translate([- (size.x/2  - diag/2 + 1/2*slack), -1.2*slack])
        circle(sqrt(2) * slack);
        
        translate([size.x/2  - diag/2 + 1/2*slack, -1.2*slack])
        circle(sqrt(2) * slack);
      }
      
      translate([-size.x/2, 0])
      square(make_2D(size));

      dovetail_2D([size.x + 2*slack, size.y], true);
    }
}

// Draws 3D male/female dovetail.

module dovetail(size, male, slack=undef, connect_y = undef) {
  slack = is_undef(slack) ? dovetail_default_slack() : slack;
  linear_extrude(size.z)
  dovetail_2D(size, male, slack, connect_y = connect_y);
}


translate([0, -10, 0])
dovetail([20, 5, 3], true, connect_y = 2);

// Applies dovetail part to the children geometry. 
// Cuts outs appropriate place for the "female" version.

module apply_dovetail(size, pos, angle, male, slack=undef, connect_y = undef) {
  slack = is_undef(slack) ? dovetail_default_slack() : slack;
  if (male)
    union () {
      children();

      translate(pos)
      rotate(angle)
      dovetail(size, true, slack, connect_y = connect_y);      
    }
  else
    union () {
      difference () {
        children();
        
        translate(pos)
        rotate(angle)
        translate([-size.x/2, -size.y, -inf])
        cube(size + [0, 0, 2*inf]);
      }
      
      translate(pos)
      rotate(angle)
      dovetail(size, false, slack);
    }
}

apply_dovetail([20, 3, 3], [40, 30], 90, true, connect_y = 2)
cube([40, 40, 3]);