spatula_length = 60;
spatula_thickness = 1;

$fn = 50;

spatula_width = 2;

linear_extrude(spatula_thickness)
difference () {
    union () {
        translate([0, -spatula_width/2])
        square([spatula_length, spatula_width]);
        polygon([[0, spatula_width/2],
                 [-spatula_width/2, 0],
                 [0, -spatula_width/2]]);
    }

    polygon([[spatula_length, spatula_width/2],
             [spatula_length - spatula_width/2, 0],
             [spatula_length, -spatula_width/2]]);
}

translate([0, - 2 * spatula_width])
linear_extrude(spatula_thickness)
difference () {
    union () {
        translate([0, -spatula_width/2])
        square([spatula_length, spatula_width]);
        circle(d = spatula_width);
    }
    
    translate([spatula_length + spatula_width/2, 0])
    circle(r = spatula_width/sqrt(2));
}

translate([0, - 4 * spatula_width])
linear_extrude(spatula_thickness)
translate([0, -spatula_width/2])
square([spatula_length, spatula_width]);
