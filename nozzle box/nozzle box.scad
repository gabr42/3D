include <../lib/helpers.math.scad>
use <../lib/helpers.lists.scad>
use <../lib/solids.scad>

// global configuration

num_nozzles = 5;
nozzle_names = ["0.25", "0.4", "0.6", "0.4S", "0.6S"];
spacing = 3; // mm
nozzle_hole_d = 6; // mm
mount_screw_d = 3; // mm
mount_screw_head_d = 6; // mm
mount_screw_head_h = 2.3; // mm
mount_screw_hole_bot_plate_h = 0; // mm
nut_d = 9.7; // mm
nut_h = 5.8; // mm
top_cover_h = 1.5; // mm
top_plate_h = 5; // mm
bot_plate_h = 8; // mm 
box_round = 1; // mm

// fine-tuning parameters to make the designed holes slightly bigger than required

nozzle_hole_slack = 0.5; // mm
mount_hole_slack = 0.0; // mm
mount_screw_slack_top = 0.0; // mm
mount_screw_slack_bottom = -0.1; // mm
nut_slack_top = 0.6; // mm
nut_slack_bottom = 0.4; // mm

// printing parameters

layer_height = 0.2; // mm

// precision

$fn = $preview ? 20 : 50;

// pre-calc some globals

$nut_r = hypoth(nut_d/2, nut_d/4);
$nozzle_r = max($nut_r + max(nut_slack_top, nut_slack_bottom)/2, nozzle_hole_d/2 + nozzle_hole_slack/2);
$box_h = $nozzle_r * 2 + spacing * 2;
$box_w = ($nozzle_r * 2 + spacing) * num_nozzles - spacing + 2 * (2 * spacing + mount_screw_head_d + mount_hole_slack);
$first_center = [2 * spacing + mount_screw_head_d + mount_hole_slack + $nozzle_r, $box_h/2, 0];
$center_dist = [$nozzle_r * 2 + spacing, 0, 0];

echo(str("Making ", $box_w, " x ", $box_h, " box for ", num_nozzles, " nozzles"));

// generate objects

translate([0, 2 * $box_h, 0])
bottom();

translate([0, $box_h, top_plate_h])
rotate(180, [1, 0, 0])
top();

// objects

module bottom () {
  difference () {
    make_box([$box_w, $box_h, bot_plate_h], false);

    make_nut_holes_bottom();

    make_screw_holes_bottom();
  }

  if (!is_undef(nozzle_names))
     make_nozzle_names();
}

module top () {
  make_screw_holes_top()
  difference () {
    make_box([$box_w, $box_h, top_plate_h], true);

    make_nozzle_holes();

    make_nut_holes_top();
  }
}

// workers

module make_box (size, round_on_top) {
    if (box_round == 0)
      cube(size);
    else if (round_on_top) {
      rcube([size.x, size.y, size.z - box_round], box_round); 

      translate([0, 0, size.z - 2 * box_round])
      scube([size.x, size.y, 2 * box_round], box_round);
    }
    else {
      translate([0, 0, box_round])
      rcube([size.x, size.y, size.z - box_round], box_round); 

      scube([size.x, size.y, 2 * box_round], box_round);
    }
}

module make_nozzle_names () {
  rotate(90, [1, 0, 0])
  for (i = [1:min(num_nozzles, len(nozzle_names))]) {
    translate(replace($first_center + $center_dist * (i-1), 1, bot_plate_h/4))
    linear_extrude(0.5)
    text(nozzle_names[i-1], 4, "Arial:bold", halign="center", valign="bottom");
  }
}

module make_nozzle_holes () {
  translate([0, 0, top_plate_h])
  for (i = [1:num_nozzles]) {
    translate([0, 0, - top_cover_h - inf])
    translate($first_center + $center_dist * (i-1))
    cylinder(d = nozzle_hole_d + nozzle_hole_slack, h = top_cover_h + 2 * inf);
  }
}

module make_nut_holes_top () {
  for (i = [1:num_nozzles]) {
    translate([0, 0, - nut_h + top_plate_h - top_cover_h])
    translate($first_center + $center_dist * (i-1))
    cylinder(r = $nut_r + nut_slack_top/2, h = nut_h + inf, $fn = 6);
  }
}

module make_nut_holes_bottom () {
  bot_h = top_plate_h - top_cover_h - nut_h;
  if (bot_h < 0)
    translate([0, 0, bot_plate_h])
    for (i = [1:num_nozzles]) {
      translate([0, 0, bot_h])
      translate($first_center + $center_dist * (i-1))
      cylinder(r = $nut_r + nut_slack_bottom/2, h = - bot_h + inf, $fn = 6);
    }
}

module make_screw_holes_top () {
  make_screw_hole_top([spacing + mount_screw_head_d/2, $box_h/2, 0])
  make_screw_hole_top([$box_w - (spacing + mount_screw_head_d/2), $box_h/2, 0])
  children();
}

module make_screw_hole_top(position) {
  difference () {
    children();

    translate(position) {
      translate([0, 0, top_plate_h - mount_screw_head_h])
      cylinder(d = mount_screw_head_d, h = mount_screw_head_h + inf);

      translate([0, 0, top_plate_h - mount_screw_head_h + layer_height/2])  
      cube([mount_screw_head_d, mount_screw_d, 2*layer_height], center = true);

      translate([0, 0, top_plate_h - mount_screw_head_h + layer_height/2])  
      cube([mount_screw_d, mount_screw_d, 4*layer_height], center = true);

      translate([0, 0, - mount_screw_head_h])
      cylinder(d = mount_screw_d + mount_screw_slack_top, h = top_plate_h + inf);
    }
  }
}

module make_screw_holes_bottom () {
  translate([spacing + mount_screw_head_d/2, $box_h/2, 0])
  make_screw_hole_bottom();

  translate([$box_w - (spacing + mount_screw_head_d/2), $box_h/2, 0])
  make_screw_hole_bottom();
}

module make_screw_hole_bottom () {
  translate([0, 0, mount_screw_hole_bot_plate_h])
  cylinder(d = mount_screw_d + mount_screw_slack_bottom, h = bot_plate_h + 2 * inf);
}