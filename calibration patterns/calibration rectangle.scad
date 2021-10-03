extrusion_width = 0.42;
layer_height = 0.6;

width = 100;
height = 20;
spacing = 0.5;

module line () {
  cube([width, extrusion_width, layer_height]);
}

module zig_zag (lastline = false) {
  line();
  
  translate([0, spacing + extrusion_width, 0])
  line();
  
  color("red")
  translate([width - extrusion_width, 0, 0])
  cube([extrusion_width, spacing + 2*extrusion_width, layer_height]);

  if (!lastline) {  
    color("red")
    translate([0, extrusion_width + spacing, 0])
    cube([extrusion_width, spacing + 2*extrusion_width, layer_height]);  
  }
}


step = 2*extrusion_width + 2*spacing;
count = floor(height / step);
for (i = [1:count])
  translate([0, (i-1) * step, 0])
  zig_zag(i == count);