include <helpers.scad>
use <curves.scad>
use <mesh.scad>

// makes a polyhedron out of a mesh

module mesh_polyhedron(mesh) {
  polyhedron(mesh, make_band_faces(mesh));
}

// renders a band sinusoidally oscillating along y and z axes

module sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  wsin = make_band_points(
           wave_points(length, yheight, zheight, num_waves, offset, offset + 90),
           ythick, zthick);
  mesh_polyhedron(wsin);  
}    

// tester for sinus_spiral()

module test_sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset = 0) {
  color("red")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset);
  
  color("green")
  sinus_spiral(length, yheight, zheight, ythick, zthick, num_waves, offset + 180);
}

//test_sinus_spiral(80, 10, 5, 5, 5, 2, $fn=50);

// renders a band based on segment_line()

module slab(length, dy, dz) {
  mesh_polyhedron(make_band_points(segment_line([0, 0, 0], [length, 0, 0]), dy, dz));
}

// renders a torus segment

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