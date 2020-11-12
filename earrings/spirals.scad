use <helpers.lists.scad>
use <geometry.scad>
use <geometry.manipulators.scad>
use <curves.scad>
use <mesh.solids.scad>
use <solids.scad>

$draft = $preview;
$fn = $preview && $draft ? 30 : 150;
$fa = $preview && $draft ? 25 : 5;
$fs = $preview && $draft ? 30 : $draft ? 100 : 200;

//make = "twist1";
//make = "twist1_lp";
//make = "twisty4";
//make = "twisty5";
//make = "twisty6";
//make = "tree1";
//make = "tree2";

if (make == "twist1")
  //rotate(5, v=[0, 1, 0])
  twist1();

if (make == "twist1_lp")
  //rotate(5, v=[0, 1, 0])
  twist1($fs=10, $fn=4);

if ((make == "twisty4") || (make == "twisty4a") || (make == "twisty4b"))
  translate([0, 0, 10])
  union () {
    if ((make == "twisty4") || (make == "twisty4a"))
      remove_above_z(42)
      twisty([0], [-360*5/2], height=70, height_center=10, r = 6);
    if ((make == "twisty4") || (make == "twisty4b"))
       twisty([0], [360*5/2-360], height=70, height_center=10, r = 6);
  }

if ((make == "twisty5") || (make == "twisty5a") || (make == "twisty5b") || (make == "twisty5c") || (make == "twisty5d") || (make == "twisty5e"))
  translate([0, 0, 10])
  union () {
    if ((make == "twisty5") || (make == "twisty5a"))
      twisty5(0);
    if ((make == "twisty5") || (make == "twisty5b"))
      twisty5(1);
    if ((make == "twisty5") || (make == "twisty5c"))
      twisty5(2);
    if ((make == "twisty5") || (make == "twisty5d"))
      twisty5(3);
    if ((make == "twisty5") || (make == "twisty5e"))
      twisty5(4);
  }
module twisty5 (idx) {
  twisty([0], [270 + 72*idx], height=70, height_center=10, r=5.5, offset=3);
}

if ((make == "twisty6") || (make == "twisty6a") || (make == "twisty6b") || (make == "twisty6c"))
  translate([0, 0, 10])
  union () {
    if ((make == "twisty6") || (make == "twisty6a"))
      twisty6(0);
    if ((make == "twisty6") || (make == "twisty6b"))
      twisty6(1);
    if ((make == "twisty6") || (make == "twisty6c"))
      twisty6(2);
  }
module twisty6 (idx) {
  twisty([0], [540 + 60*idx:180:899], r=5.5, height=70, height_center=10, offset=3);
}

if ((make == "tree1") || (make == "tree1a") || (make == "tree1b"))
  union () {
    if ((make == "tree1") || (make == "tree1a"))
      tree(height = 55, twist = 720, r = 10, d = 0.4, rotate=[0]);
    if ((make == "tree1") || (make == "tree1b"))
      tree(height = 55, twist = 720, r = 10, d = 0.4, rotate=[180]);
  }  
  
if ((make == "tree2") || (make == "tree2a") || (make == "tree2b") || (make == "tree2c"))
  union () {
    if ((make == "tree2") || (make == "tree2a"))
      tree(height = 55, twist = 720, r = 10, d = 3, rotate=[0]);
    
    if ((make == "tree2") || (make == "tree2b"))
      tree(height = 55, twist = 720, r = 10, d = 3, rotate=[180]);
    
    if ((make == "tree2") || (make == "tree2c"))
      translate([0, 0, 44])
      color("red")
      cylinder(r1 = 1.5, r2 = 0.5, h = 8);
  }  
      
////////////////

module twist1 () {
  rotate(15, [0,1,0])
  multi_twister($fs,
    translate = [0, 0, 50],
    angles = [55, 90, 90],
    initial_angles = [-15, 0, 0],
    origins = [[0,0], [0,0], [3, 5]],
    vs = [[0,1,0], [0,0,1], [0,0,1]],
    scale = [0.5, 0.25])
  scale([1, 0.5])
  circle(5);
}

module twisty (rotations, twists, height=30, r = 3, from_center=true, height_center=undef, offset=undef) {
  twistyX(rotations, twists, height, r, from_center, height_center, offset)
    scale([1/2, 1])
    circle(r = r/2);
}

module twistyX (rotations, twists, height=30, r = 3, from_center=true, height_center=undef, offset=undef) {
  for (rot = rotations)
    rotate(rot)
    for (twist = twists) {
      linear_extrude(height, twist=twist)
      translate([0, -r - (is_undef(offset) ? 0 : offset)])
      children();

      if (from_center) {
        h = is_undef(height_center) ? height/9 : height_center;
        rotate(180)
        translate([0, r/2 + (is_undef(offset) ? 0 : offset)/2, -h])
        linear_extrude(h, twist = sign(twist) * 180)
        translate([0, -r/2 - (is_undef(offset) ? 0 : offset)/2])
        children();
      }
    }
}

module arcX(r, d1, dz) {
  remove_under_x(0)
  remove_under_y(0)
  linear_extrude(dz*1.001)
  difference () {
    circle(r = r);
    circle(r = r-d1);
  }
  
  linear_extrude(dz*1.001) {
    translate([r - d1/2, 0])
    circle(d = d1);
    translate([0, r - d1/2])
    circle(d = d1);
  }
}

module tree(height, twist, r, d, rotate) {
  for (rot = rotate)
  rotate(rot) {
  for (z = [0:0.1:height]) 
    translate([0, 0, z]) 
    {
      dd = -(height*1.2)/(height*1.2);
      sc = (height*1.2-z)/(height*1.2);
      rotate(z/height*twist)
      translate([dd, dd])
      scale([sc, sc, 1])
      render()
      arcX(r, d, 0.1);
    }
  }
}
