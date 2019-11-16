color([1,1,0])
import("c:/0/original-prusa-i3-mk3s/Einsy-base.stl");

color([1,0,1])
translate([0,92,51])
rotate(180, [1,0,0])
import("c:/0/original-prusa-i3-mk3s/Einsy-doors.stl");


translate([0,-30,0])
import("c:/0/original-prusa-i3-mk3s/Einsy-hinges.stl");

color("red")
translate([16.5,-4,0])
cube([94,4,4.8]);