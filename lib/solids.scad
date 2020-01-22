include <helpers.math.scad>
use <geometry.scad>

// Rotates geometry for angle `a`, around vector `v`, origin in point `origin`.
// https://stackoverflow.com/a/45826244/4997

module rotate_around(origin, angle, v) {
  translate(origin)
  rotate(angle, v)
  translate(-origin)
  children();   
}

// Rotates geometry by multiple angles around multiple origins and multiple vectors.

module multi_rotate_around(origins, angles, vs, idx = undef) {
  idx = initialize(idx, len(origins)-1);
  if (idx < 0)
    children();
  else
//    echo(origins[idx], angles[idx], vs[idx])
    rotate_around(origins[idx], angles[idx], vs[idx])
    multi_rotate_around(origins, angles, vs, idx-1)
    children();
}

// Removes all parts of children geometry lying before/below the `limit`.

module remove_under_x(limit) {
  intersection () {
    children();
    
    translate([500 + limit, 0, 0])
    cube([1000, 1000, 1000], center = true);
  }
}

module remove_under_y(limit) {
  intersection () {
    children();
    
    translate([0, 500 + limit, 0])
    cube([1000, 1000, 1000], center = true);
  }
}

module remove_under_z(limit) {
  intersection () {
    children();
    
    translate([0, 0, 500 + limit])
    cube([1000, 1000, 1000], center = true);
  }
}

// Removes all parts of children geometry lying after/above the `limit`.

module remove_above_x(limit) {
  intersection () {
    children();
    
    translate([-500 + limit, 0, 0])
    cube([1000, 1000, 1000], center = true);
  }
}

module remove_above_y(limit) {
  intersection () {
    children();
    
    translate([0, -500 + limit, 0])
    cube([1000, 1000, 1000], center = true);
  }
}

module remove_above_z(limit) {
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

// Renders a cylinder-rounded cube with:
//   `size` = cube size, all dimensions must be >= 1
//   `radius` = 
//      1 value: used on all corners
//      2 values: first value for front, second for back corners
//      4 values: specific value for each corner [FrontLeft, FR, BR, BL]
// https://blog.prusaprinters.org/parametric-design-in-openscad/

module rcube(size, radius) {
    if(is_num(radius)) {
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


// rcube([50, 30, 10], 1);
// rcube([20, 20, 10], [0, 0, 5, 5], $fn=50);

// Renders a sphere-rounded cube with:
//   `size` = cube size, all dimensions must be >= 1
//   `radius` = 
//      1 value: used on all corners
//      2 values: [bottom corners, top corners]
//      4 values: [FrontLeftBottom/FLT, FRB/FRT, BRB/BRT, BLB/BLT]
//      8 values: specific value for each corner [FLB, FRB, BRB, BLB, FLT, FRT, BRT, BLT]

module scube(size, radius) {
    if(is_num(radius)) {
        // The same radius on all corners
        scube(size, [radius, radius, radius, radius, radius, radius, radius, radius]);
    } else if(len(radius) == 2) {
        // Different radii on each layer
        scube(size, [radius[0], radius[0], radius[0], radius[0], radius[1], radius[1], radius[1], radius[1]]);
    } else if(len(radius) == 4) {
        // Different radii on each vertical
        scube(size, [radius[0], radius[1], radius[2], radius[3], radius[0], radius[1], radius[2], radius[3]]);
    } else if(len(radius) == 8) {
        // Different radius on different corners
        hull() {
            // FLB
            if(radius[0] == 0) cube([1, 1, 1]);
            else translate([radius[0], radius[0], radius[0]]) sphere(r = radius[0]);
            // FRB
            if(radius[1] == 0) translate([size[0] - 1, 0]) cube([1, 1, 1]);
            else translate([size[0] - radius[1], radius[1], radius[1]]) sphere(r = radius[1]);
            // BRB
            if(radius[2] == 0) translate([size[0] - 1, size[1] - 1]) cube([1, 1, 1]);
            else translate([size[0] - radius[2], size[1] - radius[2], radius[2]]) sphere(r = radius[2]);
            // BLB
            if(radius[3] == 0) translate([0, size[1] - 1]) cube([1, 1, 1]);
            else translate([radius[3], size[1] - radius[3], radius[3]]) sphere(r = radius[3]);
            // FLT
            if(radius[4] == 0) translate([0, 0, size[2] - 1]) cube([1, 1, 1]);
            else translate([radius[4], radius[4], size[2] - radius[4]]) sphere(r = radius[4]);
            // FRT
            if(radius[5] == 0) translate([size[0] - 1, 0, size[2] - 1]) cube([1, 1, 1]);
            else translate([size[0] - radius[5], radius[5], size[2] - radius[5]]) sphere(r = radius[5]);
            // BRT
            if(radius[6] == 0) translate([size[0] - 1, size[1] - 1, size[2] - 1]) cube([1, 1, 1]);
            else translate([size[0] - radius[6], size[1] - radius[6], size[2] - radius[6]]) sphere(r = radius[6]);
            // BLT
            if(radius[7] == 0) translate([0, size[1] - 1, size[2] - 1]) cube([1, 1, 1]);
            else translate([radius[7], size[1] - radius[7], size[2] - radius[7]]) sphere(r = radius[7]);
        }
    } else {
        echo("ERROR: Incorrect length of 'radius' parameter. Expecting integer or vector with length 2, 4 or 8.");
    }
}

//scube([20, 20, 10], 5, $fn=50);
//scube([20, 20, 10], [0,0,5,5], $fn=50);

// Twists a 2D polygon around origin and at the same time translates and scales it.

module twister (num_steps, translate, angle, origin = [0, 0], v = [0, 0, 1], scale = 1) {
  ones = is_num(scale) ? 1 : [for (i = [1:1:len(scale)]) 1];
  angle_step = angle/num_steps;
  translate_step = translate/num_steps;
  scale_step = (scale - ones)/num_steps;

  for (i = [0:1:num_steps-2])
  hull () {
    translate(translate_step * i)
    rotate_around(origin, angle_step * i, v)
    scale(ones + scale_step * i)
    linear_extrude(0.01)
    children();

    translate(translate_step * (i+1))
    rotate_around(origin, angle_step * (i+1), v)
    scale(ones + scale_step * (i+1))
    linear_extrude(0.01)
    children();
  }
}

// twister($fn = 50, $fa = 3,
//   num_steps = 30,
//   translate = [0, 0, 20],
//   angle = 60,
//   scale = [0.5, 0.25] // or just a number, for example: 0.75
//)
// scale([1, 0.5])
// circle(5);

// Twists a 2D polygon around multiple origins and at the same time translates and scales it.

module multi_twister (num_steps, translate, angles, initial_angles = undef, origins = [[0, 0]], vs = undef /*[0, 0, 1]*/, scale = 1) {
  ones = is_num(scale) ? 1 : [for (i = [1:1:len(scale)]) 1];
  vs = initialize(vs, [for (i = [1:1:len(angles)]) [0,0,1]]);
  angles_steps = angles/(num_steps-1);
  initial_angles = initialize(initial_angles, [for (i = [1:1:len(angles)]) 0]);
  translate_step = translate/(num_steps-1);
  scale_step = (scale - ones)/(num_steps-1);

  for (i = [0:1:num_steps-2]) 
  hull () {
    translate(translate_step * i)
    multi_rotate_around(origins, initial_angles + angles_steps * i, vs)
    scale(ones + scale_step * i)
    linear_extrude(0.01)
    children();

    translate(translate_step * (i+1))
    multi_rotate_around(origins, initial_angles + angles_steps * (i+1), vs)
    scale(ones + scale_step * (i+1))
    linear_extrude(0.01)
    children();
  }
}

//multi_twister(
//  num_steps = 20,
//  translate = [0, 0, 20],
//  angles = [0, 120],
//  origins = [[0,0], [0, 10]],
//  scale = [0.75, 0.5]
//)
//scale([1, 0.5])
//circle(5);
