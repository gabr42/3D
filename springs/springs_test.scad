use <arc.scad>;
use <polyline2d.scad>;
use <hull_polyline2d.scad>;
use <archimedean_spiral.scad>;

$fn = 100;
$fa = 1;

//translate([20, 0, 0])
//spring1();

translate([-20, -20, 0])
spring2();

spring3();

///////////////

module spring1 () {
  points_angles = archimedean_spiral(
      arm_distance = 1.2,
      init_angle = 180,
      point_distance = 0.3,
      num_of_points = 110 
  ); 

  points = [for(pa = points_angles) pa[0]];

  linear_extrude(4)
  hull_polyline2d(points, width = 0.6);

  translate([3.32, 0, 0])
  cube([0.6, 30, 4]);

  cylinder(d=2, h=10);
}

module s2_arc () {
  arc(radius = 3, angle = [-90, 180], width = 0.6);
  
  translate([-1.5, -3.03-0.3])
  square([1.5, 0.6]);
  
  translate([-3.03-0.3, -1.5])
  square([0.6, 1.5]);
}

module s2_left () {
  translate([-20 - 4.5, -3-0.3])
  square([20, 0.6]);
}

module s2_top () {
  translate([-3-0.3, -20 - 4.5])
  square([0.6, 20]);
}

module s2_left_conn () {
  translate([-6, -3-0.3])
  square([6, 0.6]);
}

module s2_top_conn () {
  translate([-3-0.3, -6])
  square([0.6, 6]);
}

module spring2 () {
  linear_extrude(3.9) {
    s2_left();
    s2_arc();
    s2_top();
  }
  
  for (i = [0:1:38]) 
  translate([0, 0, i * 0.1])
  linear_extrude(0.1) {
    if (i % 4 == 2) s2_left_conn();
    if (i % 4 == 0) s2_top_conn();
  }
}

module s3_arc (offset) {
  step = 10; overlap = 1;
  for (a = [-90:step:180])
  if (abs(a % (2*step)) != offset*step)
  arc(radius = 3, angle = [a-1, a+step+1], width = 0.6);
}

module spring3 () {
  linear_extrude(3.9) {
    s2_left();
    s2_top();
  
    translate([-1.5, -3.03-0.3])
    square([1.5, 0.6]);
    
    translate([-3.03-0.3, -1.5])
    square([0.6, 1.5]);
  }
  
  for (i = [0:1:38]) 
  translate([0, 0, i * 0.1])
  linear_extrude(0.1) {
    if (i % 4 == 2) s2_left_conn();
    s3_arc((i == 0) || (i == 38) ? -1 : i % 2);
    if (i % 4 == 0) s2_top_conn();
  }
}