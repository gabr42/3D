render_button_base = true;
render_button_labels = true;

render_housing_top = true;
render_housing_bottom = true;
  
make_magnet_slot = true;

wheel_d = 40;
wheel_h = 5;
wheel_bevel = 1;

nozzle_names = ["0.25", "0.4", "0.4S", "0.6", "0.6S", "0.8"];
label_height = 1;
label_distance = wheel_d/4;

use <BebasNeue-Regular.ttf>
font_name = "Bebas Neue";
//http://bebasneue.com/

font_size = 6;

housing_wall = 5;
housing_top_bottom = 1.6;
housing_size = wheel_d - housing_wall*1.25;
vert_spacing = 0.4;
hor_spacing = 0.8;

magnet_slot_d = 8;
magnet_slot_h = 1;

housing_cutout_distance = label_distance*1.5;
housing_back_cutoff = label_distance + font_size;

connector_d = 8;
connector_h = 1;
connector_d_spacing = 0.4;
connector_h_spacing = 0.2;

$fn = 100;

//

housing_h_net = wheel_h + label_height + vert_spacing;

if (render_button_base)
  wheel();
  
if (render_button_labels)
  color("red")
  labels();

if (render_housing_top || render_housing_bottom) {
  translate([0, 0, label_height/2])
  rotate(90) {
    if (render_housing_top)
      color("aqua")
      housing_top();
    
    if (render_housing_bottom)
      color("lime")
      housing_bottom(cylinder_cutout_reduction_factor = 1);
  }
}

//

module wheel () {
  difference () {
    union () {
      cylinder(h = wheel_h - 2*wheel_bevel, d = wheel_d, center = true);
      
      for (side = [0:1])
        mirror(v=[0,0,side])
        translate([0, 0, (wheel_h - wheel_bevel)/2])
        cylinder(h = wheel_bevel, d2 = wheel_d - 2 * wheel_bevel, d1 = wheel_d, center = true);
    }
  
    for (a=[0:20:359]) {
      rotate(a)
      translate([wheel_d/2, 0, 0])
      cylinder(h = wheel_h + 2, d = wheel_d/10, center = true);
    }
    
    translate([0, 0, - wheel_h/2 - 0.01])
    connector(connector_h, connector_d);
  }

  translate([0, 0, wheel_h/2])
  connector(connector_h - connector_h_spacing, connector_d - connector_d_spacing);
}

module labels () {
  num_labels = len(nozzle_names);
  for (i=[1:num_labels]) 
    rotate(-360/num_labels*(i-1))
    translate([0, label_distance, wheel_h/2])
    linear_extrude(label_height)
    text(nozzle_names[i-1], size = font_size, halign = "center", font = font_name);
}

module housing_stubs (h, cylinder_cutout_reduction_factor = 1) {
  difference () {
    cylinder(h = h, d = housing_size + 2*housing_wall, center = true, $fn = 6);

    cylinder(h = h + 1, d = (wheel_d + hor_spacing) * cylinder_cutout_reduction_factor, center = true);
  }
}  

module housing_top_bottom (make_magnet_hole = false) {
  difference () {
    union () {
      cylinder(h = housing_top_bottom/2, d = housing_size + 2*housing_wall, center = true, $fn = 6);

      translate([0, 0, -housing_top_bottom/2])
      cylinder(h = housing_top_bottom/2, d2 = housing_size + 2*housing_wall, d1 = housing_size + 2*housing_wall - housing_top_bottom/2, center = true, $fn = 6);
    }
    
    if (make_magnet_hole) 
      translate([0, 0, - housing_top_bottom*3/4 - 0.01])
      cylinder(h = magnet_slot_h, d = magnet_slot_d);
  }    
}

module housing (render_bottom = true, extend_stubs = false, cylinder_cutout_reduction_factor = 1) {  
  difference () {  
    difference () {
      rotate(30)
      union () {
        housing_stubs(housing_h_net, cylinder_cutout_reduction_factor);
        
        if (extend_stubs)
          translate([0, 0,  - housing_h_net/2 - housing_top_bottom/2])
          intersection () {
            housing_stubs(housing_top_bottom);
            
            translate([0, 0, housing_top_bottom/4])
            housing_top_bottom();
          }
          
        for (side = [(render_bottom ? 0 : 1):1])
          mirror(v=[0,0,side])
          translate([0, 0, - housing_h_net/2 - housing_top_bottom/4]) 
          housing_top_bottom();
      }

      translate([0, 0, housing_h_net/2 - 0.01]) 
      connector(connector_h, connector_d);

      translate([housing_cutout_distance, 0, housing_top_bottom/2 + 1])
      cylinder(h = housing_h_net + housing_top_bottom + 2, d = housing_size/1.7, center = true, $fn = 5);            
    }
    
    translate([housing_back_cutoff, -wheel_d/2, -wheel_h*2])
    cube([wheel_d, wheel_d, wheel_h*4]);
  }
}

module housing_top () {
  housing(false, true);
}

module connector (connector_h, connector_d) {
  cylinder(h = connector_h/2, d = connector_d);

  translate([0, 0, connector_h/2])
  cylinder(h = connector_h/2, d1 = connector_d, d2 = connector_d - connector_h);  
}

module housing_bottom (cylinder_cutout_reduction_factor = 1) {
  translate([0, 0, - housing_h_net/2 - housing_top_bottom/4]) 
  rotate(30) {
    difference () {
      housing_top_bottom(make_magnet_hole = make_magnet_slot);
      
      housing_stubs(housing_top_bottom + 2, cylinder_cutout_reduction_factor);
    }
    
    translate([0, 0, housing_top_bottom/4]) 
    connector(connector_h - connector_h_spacing, connector_d - connector_d_spacing);
  }
}