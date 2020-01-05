include <helpers.math.scad>
use <geometry.scad>

// Rotates geometry for angle `a`, around vector `v`, origin in point `pt`.
// https://stackoverflow.com/a/45826244/4997

module rotate_around(pt, angle, v) {
  translate(pt)
  rotate(angle, v)
  translate(-pt)
  children();   
}

// Removes all parts of children geometry lying below the `limit`.

module remove_under_z (limit) {
  intersection () {
    children();
    
    translate([0, 0, 500 + limit])
    cube([1000, 1000, 1000], center = true);
  }
}

// Removes all parts of children geometry lying above the `limit`.

module remove_above_z (limit) {
  intersection () {
    children();
    
    translate([0, 0, -500 + limit])
    cube([1000, 1000, 1000], center = true);
  }
}

// Renders a torus segment.

module torus_segment(r1, r2, angle_from=0, angle_to=360) {
  rotate(angle_from)
  rotate_extrude(angle = (angle_to - angle_from))
  translate([r1, 0, 0])
  circle(r = r2);
}

// Wraps a solid lying along the x axis with z close to 0
// around cylinder with radius r and axis [0, y, -r].
// The solid should lay at z<=0, near z=0.
// WARNING: EXTREMELY SLOW

module wrap_solid_around_cylinder(x_from, x_to, r, inner) {
  let (sign = (is_undef(inner) || (!inner)) ? 1 : -1)
  let (a_from = 360*x_from/(2*pi*r))
  let (a_to = 360*x_to/(2*pi*r))
  let (steps = (is_undef($fn) || ($fn <= 0)) ? ceil(((a_to - a_from)/$fa)) : $fn)
  let (a_step = (a_to - a_from)/steps) 
  let (x_step = (x_to - x_from)/steps) {
    for (interval = [1:steps]) {
      let (a = a_from + (interval - 1) * a_step + a_step/2) 
      let (x = x_from + (interval - 1) * x_step + x_step/2) {
        rotate_around([0, 0, - sign * r], sign * a, [0, 1, 0])
        translate ([-x, 0, 0])
        intersection () {
          translate([x, 0, 0])
          cube([x_step, 100, 100], center = true);
      
          children();
        }  
      }
    }
  } 
}

// tests for wrap_solid_around_cylinder

module test_wrap_solid_around_cylinder_outer() {
  wrap_solid_around_cylinder(-20, 20, 15, $fa=1) {
    translate([0, 0, -3])
    linear_extrude(height = 3, convexity = 5)
    text("xX.Xx", 
         size=8,
         font="Arial",
         halign="center",
         valign="center");  
  }
}

module test_wrap_solid_around_cylinder_inner() {
  wrap_solid_around_cylinder(-20, 20, 15, $fa=1, inner = true) {
    linear_extrude(height = 3, convexity = 5)
    text("xX.Xx", 
         size=8,
         font="Arial",
         halign="center",
         valign="center");  
  }
}

//test_wrap_solid_around_cylinder_outer();
//test_wrap_solid_around_cylinder_inner();

// Creates a series of two-surface hulls. Each can be painted in a different color.

module hull_chain (segment_colors) {
  for (i = [0:1:$children - 2]) {
    color(is_undef(segment_colors) ? undef : i < len(segment_colors) ? segment_colors[i] : segment_colors[len(segment_colors)-1])
    hull () {
      children(i);

      children(i+1);
    }
  }
}

// Creates a thin slab (typically, size.z = small). Can optionally hollow it out and geenerate sparse support.
// hollow: anyting = remove insides, keep `wall_thick` thick wall (defaults to `size.z`)
//         D = remove insides, add diagonal supports `support_thick` thick, spaced at `support_space` or a bit less, angled at `support_angle` (default 45)

module slab (size, hollow, wall_thick, support_thick, support_space, support_angle) {
  wall = is_undef(wall_thick) ? size.z : wall_thick;
  angle = is_undef(support_angle) ? 45 : support_angle;

  // echo("size = ", size, ", hollow = ", hollow, ", wall_thick = ", wall_thick, ", support_thick = ", support_thick, ", support_angle = ", support_angle);

  difference () {
    linear_extrude(size.z)
    square([size.x, size.y]);

    
    if (hollow != undef) {
      translate([0, 0, -inf])
      linear_extrude(size.z + 2*inf)
      translate([wall, wall, 0])
      square([size.x - 2*wall, size.y - 2*wall]);
    }
  }
  
  if (hollow == "D") {
    assert(support_space != undef, "Parameter support_space is not defined!");
    assert(support_thick != undef, "Parameter support_thick is not defined!");

    diag = sqrt(pow(size.x - 2 * wall, 2) + pow(size.y - 2 * wall, 2));
    steps = ceil(diag/support_space);
    step = diag/steps;
    a = atan2(size.y - 2*wall, size.x -2*wall);
    
    intersection () {
      for (d = [step:step:diag-step+inf]) {
        translate([wall + d * cos(a), wall + d * sin(a), 0])
        rotate(-angle)
        translate([-5*size.x, -support_thick/2, 0])
        slab ([10*size.x, support_thick, size.z]);

        translate([size.x - wall - d * cos(a), wall + d * sin(a), 0])
        rotate(angle)
        translate([-5*size.x, -support_thick/2, 0])
        slab ([10*size.x, support_thick, size.z]);
      }

      linear_extrude(size.z)
      translate([wall, wall, 0])
      square([size.x - 2*wall, size.y - 2*wall]);
    }
  }
}

// Renders a rounded cube with:
//   `size` = cube size
//   `radius` = 
//      1 value: used on all corners
//      2 values: first value for front, second for back corners
//      4 values: specific value for each corner [FL, FR, BR, BL]
// https://blog.prusaprinters.org/parametric-design-in-openscad/

module rcube(size, radius) {
    if(len(radius) == undef) {
        // The same radius on all corners
        rcube(size, [radius, radius, radius, radius]);
    } else if(len(radius) == 2) {
        // Different radii on top and bottom
        rcube(size, [radius[0], radius[0], radius[1], radius[1]]);
    } else if(len(radius) == 4) {
        // Different radius on different corners
        hull() {
            // BL
            if(radius[0] == 0) cube([1, 1, size[2]]);
            else translate([radius[0], radius[0]]) cylinder(r = radius[0], h = size[2]);
            // BR
            if(radius[1] == 0) translate([size[0] - 1, 0]) cube([1, 1, size[2]]);
            else translate([size[0] - radius[1], radius[1]]) cylinder(r = radius[1], h = size[2]);
            // TR
            if(radius[2] == 0) translate([size[0] - 1, size[1] - 1])cube([1, 1, size[2]]);
            else translate([size[0] - radius[2], size[1] - radius[2]]) cylinder(r = radius[2], h = size[2]);
            // TL
            if(radius[3] == 0) translate([0, size[1] - 1]) cube([1, 1, size[2]]);
            else translate([radius[3], size[1] - radius[3]]) cylinder(r = radius[3], h = size[2]);
        }
    } else {
        echo("ERROR: Incorrect length of 'radius' parameter. Expecting integer or vector with length 2 or 4.");
    }
}


rcube([50, 30, 10], [10,10,10,10]);