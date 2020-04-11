include <helpers.math.scad>
include <solids.scad>

profile = 25;
length = 80;
thickness = 2;
slack = 0.5;

angle = 45; // not configurable
connect = (profile + slack) / sin(angle);
diag_wood = sqrt(length*length*2);

//mode = "intersect";
mode = "combine";
//mode = "slice";

if (mode == "combine") {
  color("yellow")
  jig();

  color("saddlebrown")
  wood();
} 
else if (mode == "intersect") {
  intersection () {
    jig();
    wood();
  }
}
else if (mode == "slice") {
  jig();
}

module jig () {
  translate([-thickness-inf, -thickness-inf, -inf]) {
    full_length = length + slack + 2*thickness;
    
    translate([0, 0, -thickness])
    cube([full_length, profile + slack + 2*thickness, thickness]);

    translate([0, profile + slack + thickness, 0])
    cube([full_length, thickness, profile]);

    translate([0, thickness, 0])
    cube([thickness, profile + thickness, profile]);

    translate([length + thickness + slack, 0, 0])
    cube([thickness, profile + 2*thickness, profile]);

    inner_length = length + thickness - connect;
    angle_trim_cube([inner_length, thickness, profile], angle_end = - angle);

    inner_diag = sqrt(inner_length*inner_length*2);    
    rotate_around([inner_length, thickness, 0], 45)
    translate([- inner_diag + inner_length, thickness, 0])
    angle_trim_cube([inner_diag, thickness, profile], angle_start = angle, angle_end = angle);
    
    outer_diag = sqrt(full_length*full_length*2);
    rotate_around([full_length, 0, 0], angle, [0, 0, 1])
    translate([- outer_diag + full_length, 0, 0])
    angle_trim_cube([outer_diag, thickness / sqrt(2), profile], angle_start = angle, angle_end = angle);
    
    rotate_around([full_length, 0, 0], angle, [0, 0, 1])
    translate([- outer_diag + full_length, 0, -thickness])
    angle_trim_cube([outer_diag, profile + slack + 2*thickness, thickness], angle, angle);
    
    translate([thickness, - length, 0])
    rotate(90)
    angle_trim_cube([connect, thickness, profile], -angle, angle);
  }
}

module wood () {
  cube([length, profile, profile]);
  
  rotate_around([length, 0, 0], angle, [0, 0, 1])
  translate([- diag_wood + length, 0, 0])
  angle_trim_cube([diag_wood, profile, profile], 45, 45);
}