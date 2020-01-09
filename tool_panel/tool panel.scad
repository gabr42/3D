use <../lib/solids.scad>

rect_big = [7.4, 8.4, 2.5];
rect_small = [2.9, 4.8, 2.6];
connect_x2_vert = [rect_big.x, 40, 4];
connect_x1_vert = [rect_big.x, 30, 4];
dist_x2_vert = 25;
connect_x1_horz = [30, rect_big.y, 4]; 
grip_profile = [4, connect_x1_horz.y, 0.1];
grip_dist = 16;
diag_support_offs = [15, 20];

$fn = 50;

module lock () {
  color("red")
  rcube(rect_big, 1);

  color("green")
  translate([(rect_big.x - rect_small.x)/2, (rect_big.y - rect_small.y)/2, rect_big.z])
  rcube(rect_small, 0.5);
}

module vert_x2_base () {
  translate([-connect_x2_vert.x/2, (rect_big.y - rect_small.y) - connect_x2_vert.y/2, - rect_big.z - rect_small.z - connect_x1_horz.z]) {
    lock();

    translate([0, dist_x2_vert, 0])
    lock();

    translate([- (connect_x2_vert.x - rect_big.x)/2, (connect_x2_vert.y - (dist_x2_vert + rect_small.y))/2 - rect_big.y, rect_big.z + rect_small.z])
    rcube(connect_x2_vert, 1);
  }
}

//vert_x2_base();

module vert_x1_base () {
  translate([0, 0, -connect_x1_vert.z]) {
    translate([-rect_big.x/2, -rect_big.y/2, - rect_big.z - rect_small.z])
    lock();

    translate([-connect_x1_vert.x/2, -2*connect_x1_vert.y/3, 0])
    rcube(connect_x1_vert, 1);
  }
}

module horz_x1_base () {
  translate([0, 0, - rect_big.z - rect_small.z - connect_x1_horz.z]) {
    translate([-rect_big.x/2, -rect_big.y/2, 0])
    lock();

    translate([-connect_x1_horz.x/2, -connect_x1_horz.y/2, rect_big.z + rect_small.z])
    rcube(connect_x1_horz, 1);
  }
}

//horz_x1_base();

module grip_1 () {
  hull_chain() {
    rcube(grip_profile, 0.5);

    translate([4, 0, 25])
    scube(grip_profile, 0.5);
    
    translate([0, 0, 25+8])  
    scube(grip_profile, 0.5);
  }
}

module grip () {
  grip_1();

  translate([grip_profile.x + grip_dist, 0, 0])
  mirror([1,0,0])
  grip_1();
}

//grip();

module horz_x1_grip () {
  horz_x1_base();

  translate([(- grip_profile.x - grip_dist)/2, -grip_profile.y/2, 0])
  grip();
}

//horz_x1_grip();

module perp_support () {
  hull_chain() {
    rcube(grip_profile - [0, 1, 0], 0.5);

    translate([0, 0, 25])
    scube(grip_profile - [0, 1, 0], 0.5);
    
    translate([5, 0, 25+8])  
    scube(grip_profile - [0, 1, 0], 0.5);
  }

  hull () {
    translate([- diag_support_offs.x, 0, 0])
    rcube(grip_profile - [0, 1, 0], 0.5);

    translate([0, 0, diag_support_offs.y])
    rcube(grip_profile - [0, 1, 0], 0.5);
  }
}

//perp_support();

module vert_x1_perp () {
  vert_x1_base();

  rotate(90, [0,0,1])
  translate([-grip_profile.x/2, -grip_profile.y/2 + 0.5, 0])
  perp_support();
}

vert_x1_perp();
