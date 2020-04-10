use <shear.scad>

//d 35 x 40
//d 32 x 20 - 60 st.C

d1 = 35; h1 = 40;
d2 = 32; h2 = 20;
a2 = 60;
wall = 5;

$fn = $preview ? 50 : 100;

difference () {
  union () {
    cylinder(d = d1 + wall, h = h1);
   
    translate([0, 0, h1])
    cylinder(d = d2 + wall, h = h2);
    
    translate([0, 0, h1])
    cylinder(d1 = d1 + wall, d2 = d2 + wall, h = h2/4);    
  }
  
  union () {
    translate([0, 0, -0.01])
    cylinder(d = d1, h = h1 + 0.02);
   
    translate([0, 0, h1 - 0.01])
    cylinder(d = d2, h = h2 + 0.02);

    translate([0, 0, h1])
    cylinder(d1 = d1, d2 = d2, h = h2/4);
  }

  translate([0, 0, h1 + h2/4])
  shear(sx = [cos(a2),0])  
  cube(h2); 
}

