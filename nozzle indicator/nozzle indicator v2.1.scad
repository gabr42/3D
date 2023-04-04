// rendering options - select parts to be generated

render_wheel_base = true;
render_wheel_labels = true;

render_housing_top = true;
render_housing_bottom = true;

// view/placement options

// defaults: exploded simplified preview; print-ready render

$simplified = $preview; // remove wheel indentations
$exploded = true;
$explode_offset = 15;
$print_ready = !$preview; // printing layout, overrides $exploded

// build options - turn features on and off
  
nozzle_names = [".25", ".4", ".4 S", ".6", ".6 S", ".8"];

// configuration options - tune parameters

wheel_d = 40;
wheel_h = 5;
wheel_bevel = 1;

label_height = 1;
label_distance = wheel_d/4;

use <BebasNeue-Regular.ttf>
font_name = "Bebas Neue";
//http://bebasneue.com/

// alternative
//use <KENYC___.TTF>
//font_name = "Kenyan Coffee";
//https://typodermicfonts.com/freshly-brewed-kenyan-coffee/

font_size = 6;

housing_wall = 5;
housing_top_bottom = 1.6;
housing_size = wheel_d - housing_wall*1.25;
vert_spacing = 0.4;
hor_spacing = 0.8;

housing_cutout_distance = label_distance*1.6;
housing_cutout_size = housing_size/1.8;

connector_d = 8;
connector_pin_d = 4;
connector_spacing = 0.2;
connector_bump_r = 1.25;

$fn = 200;

// parts

$real_explode_offset = ($exploded && !$print_ready) ? $explode_offset : 0;

housing_h_net = wheel_h + label_height + vert_spacing;

if (render_wheel_base)
  translate([0, 0, $print_ready ? wheel_h/2 : 0])
  wheel();
  
if (render_wheel_labels)
  color("red")
  translate([0, 0, $print_ready ? wheel_h/2 : 0])
  labels();

if (render_housing_top ) 
  translate([$print_ready ? wheel_d * 1.5 : 0, 0, $print_ready ? housing_h_net - housing_top_bottom : label_height/2])
  mirror(v = [0, 0, $print_ready ? 1 : 0])
  rotate(90) 
  color("aqua")
  translate([0, 0, $real_explode_offset])
  housing_top();
 
  
if (render_housing_bottom) 
  translate([$print_ready ? -wheel_d * 1.5 : 0, 0, $print_ready ? housing_h_net - housing_top_bottom : label_height/2]) {
    color("lime")
    translate([0, 0, -$real_explode_offset])
    rotate(90)
    difference () {        
      housing_bottom();
      rotate(30)
      housing_stubs(housing_h_net + housing_top_bottom, connector_spacing);
    }
  }

// code

module chamfered_cylinder(d, r, h, chamfer, center = false) {
  translate([0, 0, center ? - h/2 : 0]) {
    cylinder(h = h - chamfer, d = d); 
  
    translate([0, 0, h - chamfer - 0.001 ])
    cylinder(h = chamfer + 0.001, d1 = d, d2 = d - chamfer*2);
  }
}

module wheel () {
  difference () {
    union () {
      cylinder(h = wheel_h - 2*wheel_bevel, d = wheel_d, center = true);
      
      for (side = [0:1])
        mirror(v=[0,0,side])
        translate([0, 0, (wheel_h - wheel_bevel)/2])
        cylinder(h = wheel_bevel, d2 = wheel_d - 2 * wheel_bevel, d1 = wheel_d, center = true);
    }

    if (!$simplified)  
    for (a=[0:20:359]) {
      rotate(a)
      translate([wheel_d/2, 0, 0])
      cylinder(h = wheel_h + 2, d = wheel_d/10, center = true);
    }
    
    num_labels = len(nozzle_names);
    for (i=[1:num_labels]) 
      rotate(-360/num_labels*(i-1))
      translate([0, connector_d/2 + connector_bump_r/2, -wheel_h])
      cylinder(r = connector_bump_r*1.2, h = wheel_h * 2);


    translate([0, 0, -wheel_h/2-wheel_bevel-1])
    cylinder(d = connector_d + connector_bump_r + connector_spacing, h = wheel_h+2*wheel_bevel+2);
  }
}

module labels () {
  num_labels = len(nozzle_names);
  for (i=[1:num_labels]) 
    rotate(-360/num_labels*(i-1))
    translate([0, label_distance, wheel_h/2])
    linear_extrude(label_height)
    text(nozzle_names[i-1], size = font_size, halign = "center", font = font_name);
}

module housing_stubs (h, spacing = 0) {
  difference () {
    cylinder(h = h, d = housing_size + 2*housing_wall + spacing, center = true, $fn = 6);

    rotate(30)
    translate([0, 0, -housing_top_bottom])
    chamfered_cylinder(h = h + 1, d = (wheel_d + hor_spacing - spacing) * 2 / sqrt(3), center = true, $fn = 6, chamfer = 1);
  }
}  

module housing_top_bottom () {
  difference () {
    union () {
      cylinder(h = housing_top_bottom/2, d = housing_size + 2*housing_wall, center = true, $fn = 6);
      
      translate([0, 0, -housing_top_bottom/2])
      cylinder(h = housing_top_bottom/2, d2 = housing_size + 2*housing_wall, d1 = housing_size + 2*housing_wall - housing_top_bottom/2, center = true, $fn = 6);
    }
  }    
}

module housing_top () {
  difference () {  
    difference () {
      rotate(30)
      union () {
        housing_stubs(housing_h_net + housing_top_bottom);
                  
        mirror(v=[0,0,1])
        translate([0, 0, - housing_h_net/2]) {
          translate([0, 0, - housing_top_bottom/4])
          housing_top_bottom();
          
          chamfered_cylinder(d = connector_pin_d, h = housing_h_net - vert_spacing/2, chamfer = 0.5);
        }
      }

      translate([housing_cutout_distance, 0, housing_top_bottom/2 + 0.5])
      cylinder(h = housing_h_net + housing_top_bottom*2 + 2, d = housing_cutout_size, center = true, $fn = 5); 
    }
  }
}

module housing_bottom () {
  translate([0, 0, - housing_h_net/2]) 
  difference () {
    union () {
      translate([0, 0, - housing_top_bottom/4]) 
      rotate(30)
      housing_top_bottom();
   
      difference () {  
        cylinder(d = connector_d, h = housing_h_net - vert_spacing);
             
        translate([0, 0, -1])
        cylinder(d = connector_pin_d + connector_spacing, h = housing_h_net + housing_top_bottom + 2);
      }
      
      translate([connector_d/2, 0, 0])
      cylinder(r = connector_bump_r, h = housing_h_net - vert_spacing);   
    }
    
    translate([(housing_size/2 + 2*housing_wall)/sqrt(2), 0, -housing_top_bottom-1])
    rotate(180) 
    cylinder(d = 5, h = housing_top_bottom*2 + 2, $fn=3);
  }
}