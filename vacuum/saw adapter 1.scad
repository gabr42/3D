use <solids.scad>

//d 35 x 40
//d 32 x 20 - 60 st.C

d1 = 35; h1 = 40;
d2 = 32; h2 = 20;
h2d = 10; r2c = 10;
wall = 3;

$fn = $preview ? 50 : 100;

module render_pipe(offset, extra_h = 0) {
  cylinder(d = d1 + 2*offset, h = h1 + extra_h);
  
  translate([0, 0, -h2d/2]) {
    cylinder(d1 = d2 + 2*offset, d2 = d1 + 2*offset, h = h2d/2);

    rotate(-90, [1, 0, 0])
    translate([0, r2c + d2/2, -r2c - d2/2]) {
      translate([0, - r2c - d2/2, 0])
      rotate(-90, [0, 1, 0])
      torus_segment(r1 = d2/2 + r2c, r2 = d2/2 + offset, angle_from = 0, angle_to = 90);

      translate([0, 0, - h2 - extra_h])
      cylinder(d = d2 + 2*offset, h = h2 + extra_h);
    }
  }
}


difference () {
  render_pipe(wall);
  
  render_pipe(0, extra_h = 0.01);
}
