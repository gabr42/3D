// Source: https://www.prusaprinters.org/prints/10370-gravity-spoolholder-for-mmu2s

module clip () {
  difference () {
    union () {
      import("gravity_spoolholder_clip_1x.stl");

      translate([0, -8, 0])
      intersection () {
        import  ("gravity_spoolholder_clip_1x.stl");
              
        translate([-70, 0, -15])
        cube([30, 30, 30]);
      }
    }
    
    translate([-61.5, 6, -15])
    cylinder(30, 2, 2, $fn=21);
    
    translate([-70, -4, -4])
    cube([20, 20, 8]);
  }
}

use <../../lib/geometry.scad>
use <../../lib/curves.scad>
use <../../lib/mesh.solids.scad>
use <../../lib/geometry.manipulators.scad>

module wheel () {
  h = 8;
  rotate_extrude(angle = 360, $fn=50)
  polygon(
    make_2D(
      g_rotate(-90, points = 
        g_translate([0, h, 0], 
          concat(
            [[-3, -h, 0]],
            
            g_translate([-2, 0, 0],
            g_rotate(90, points =
            make_segment_ellipse([0,0], 1, 0.7, 90, -90))),

            make_segment_arc([0,0], 1, -180, 0),
            
            g_translate([2, 0, 0],
            g_rotate(90, points =
            make_segment_ellipse([0,0], 1, 0.7, 90, -90))),
                
            [[3, -h, 0]]
          )
        )  
      )
    )
  );
}

module axle () {
  cylinder(20, 1.5, 1.5, $fn=21);
}

module pierced_wheel () {
  difference () {
    wheel();

    translate([0, 0, -10])
    axle();
  }
}

clip();

translate([20, 0, 0])
pierced_wheel();

scale(0.97)
translate([40, 0, 0])
axle();
