include <../lib/helpers.scad>
use <../lib/curves.scad>
use <../lib/mesh.scad>
use <../lib/solids.scad>

letter1 = "Ž";
letter2 = "P";
stamp_proStyle = true;

$fn = 100;

r = 20;
yheight = 5;
zheight = 1;
ythick = 10;
zthick = 2;
num_waves = 5;
angle = 7;

heart_size = 16;
heart_z = 2;
heart_border = 4;
heart_border_z = 2;
heart_dy = heart_size/2 + 0.2;
heart_rotatex = 26;

hearts_rotate = 0;

letter_height = 1;
letter_size = 5;
letter_dy = 1;

///
 
length = 2 * pi * r * 1.2;

mesh1 = rotate_mesh(
          translate(
            make_band_points(
              wave_points(length, yheight, zheight, num_waves, 0, 90), ythick, zthick),
            [-length/2, -yheight, 0]),                                                                    
          angle);

mesh2 = rotate_mesh(
          translate(
            make_band_points(wave_points(length, yheight, zheight, num_waves, 180, 270), ythick, zthick),
            [-length/2, -yheight, 0]),                                                                    
          angle);
        
under = rotate_mesh(
          translate(
            make_band_points(segment_line([0, 0, -zthick/2], [length, 0, -zthick/2]), ythick, zthick),
            [-length/2, -yheight, 0]
          ),
          angle);

/** /
union() {
  color("red")
  mesh_polyhedron(mesh1);

  color("green")
  mesh_polyhedron(mesh2);
  
  color("blue")
  mesh_polyhedron(under);
}
/**/

/**/
module round_mesh(mesh) {
  ring = wrap_around_cylinder(mesh, r); 
  polyhedron(ring, make_band_faces(ring, ! angle));
}

color("green")
round_mesh(mesh1);

color("red")
round_mesh(mesh2);

color("blue")
difference () {
  round_mesh(under);
  
  if (stamp_proStyle) {
    proStyle();
  }
}
/**/

module proStyle() {
  rotate(-angle)
  translate([0, (yheight + ythick)/2, - 2*r - zthick])
  linear_extrude(height = 20)
  text("proStyle", 
       size=3,
       font="Frutiger",
       halign="center",
       valign="center");  

  rotate(-angle)
  translate([0, -(yheight + ythick)/2 + 2, - 2*r - 2*zthick])
  linear_extrude(height = 20)
  text("Z nami", 
       size=3,
       font="Frutiger",
       halign="center",
       valign="center");  

  rotate(-angle)
  translate([0, -(yheight + ythick)/2 - 2, - 2*r - 2*zthick - 0.5])
  linear_extrude(height = 20)
  text("do plesa", 
       size=3,
       font="Frutiger",
       halign="center",
       valign="center");  
}

module outlined_heart(size, height, border, border_height) {
  difference () {  
    linear_extrude(height = height + border_height)
    text("♥", 
         size=size + border,
         font="Arial",
         halign="center",
         valign="center");  

    translate([0, 0, border_height + 0.01])
    linear_extrude(height = height)
    text("♥", 
         size=size,
         font="Arial",
         halign="center",
         valign="center");
  }
}

module heart_with_letter (letter) {
  outlined_heart(heart_size, heart_z, heart_border, heart_border_z);
  
  translate([0, letter_dy, heart_z])
  linear_extrude(height = letter_height)
  text(letter, 
       size=letter_size,
       font="Arial",
       halign="center",
       valign="center");  
}

module hearts (letter1, letter2) {
  translate([0, -heart_dy, 0])
  rotate(heart_rotatex)
  translate([0, heart_dy, zthick])
  heart_with_letter(letter1);
  
  translate([0, -heart_dy, 0])
  rotate(-heart_rotatex)
  translate([0, heart_dy, zthick])
  heart_with_letter(letter2);  
}

rotate(hearts_rotate)
hearts(letter1, letter2);