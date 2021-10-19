length = 100;
extrusion = 0.4;
layer = 0.2;
width_rep = 16;
width = width_rep*extrusion;

//print_material = ["RED", "GREEN"];
print_material = ["RED"];
//print_material = ["GREEN"];

//translate([0, 10, 0]) single_material();
//translate([0, 0, 0])  multi_material_layered();
translate([0, -10, 0]) multi_material_mixed();

module single_material () {
  if (should_print("RED"))
    color("red")
    cube([length, width, 3*extrusion]);
}

module multi_material_layered() {
  if (should_print("RED"))
    color("red") 
    for (i=[0:2:2])
      translate([0, 0, i*extrusion])
      cube([length, width, extrusion]);
  
  if (should_print("GREEN"))
    color("green")
    translate([0, 0, extrusion])
    cube([length, width, extrusion]);
}

module multi_material_mixed () {
  intersection () {
    for (z=[1:3])
      translate([0, (z-1)*extrusion, (z-1)*extrusion])
      for (y=[0:width_rep/4])
        translate([0, (y-1)*4*extrusion, 0]) {
          if (should_print("RED"))
            color("RED")
            cube([length, 2*extrusion, extrusion]);
          if (should_print("GREEN"))
            color("GREEN")
            translate([0, 2*extrusion, 0])
            cube([length, 2*extrusion, extrusion]);    
        }
        
    cube([length, width, 3*extrusion]);    
  }
}

function should_print(part) =
  (search([part], print_material) != [[]]);