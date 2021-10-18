height = 5;
length = 100;
extrusion = 0.45;
layer = 0.25;

//print_material = ["RED", "GREEN"];
//print_material = ["RED"];
print_material = ["GREEN"];

//translate([0, 4, 0]) single_material();
//translate([0, 2, 0]) multi_material_layered();
multi_material_mixed();

module single_material () {
  if (should_print("RED"))
    color("red")
    cube([length, 3*extrusion, height]);
}

module multi_material_layered() {
  if (should_print("RED"))
    color("red")
    two(height);
  
  if (should_print("GREEN"))
    color("green")
    one(height);
}

module multi_material_mixed () {
  for (lay = [0:height/layer/2-1]) 
    translate([0, 0, lay*layer*2]) {
      if (should_print("RED"))
      color("red")
      {    
        two();
        translate([0, 0, layer])
        one();
      }

      if (should_print("GREEN"))
      color("green") 
      {
        one();    
        translate([0, 0, layer])
        two();
      }
    }
}

module one (height = layer) {
  translate([0, extrusion, 0])
  cube([length, extrusion, height]);
}

module two (height = layer) {
  for (i = [0:1])
    translate([0, 2*extrusion*i, 0])
    cube([length, extrusion, height]);
}

function should_print(part) =
  (search([part], print_material) != [[]]);