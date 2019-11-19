use <../../external/scad_utils/hull.scad>

width = 48;
height = 103;
holes = [[10,10], [10, 93], [38, 10], [38, 93]];
screws = 3;
thick = 3;
delta = [35, -40, -20] + [0, thick, 0];
connection = [6, 40];
except_lr = [10, 70];
except_tb = [25, 12.5];

inf = 0.01;

module make_hull (points) {
  polyhedron(points=points, faces=hull(points));
}

module make_holes () {
  for (pt = holes) {
    translate([pt.x, -inf, pt.y])
    rotate(-90, [1, 0, 0])
    cylinder(h = thick + 2 * inf, r = screws/2, $fn = 50);
  }
}

module remove_material_lr () {
  c1 = [-inf, 0, (height - except_lr.y) / 2];
  r1 = [for (dy=[-inf, thick+inf], dz=[0,except_lr.y]) 
          c1 + [0,dy,dz]];
  
  c2 = c1 + [except_lr.x+inf, 0, except_lr.x];
  r2 = [for (dy=[-inf, thick+inf], dz=[0,except_lr.y - 2*except_lr.x]) 
          c2 + [0,dy,dz]];
  
  make_hull(concat(r1, r2));
  
  translate([width, 0, 0])
  mirror([1,0,0])
  make_hull(concat(r1, r2));
}

module remove_material_tb () {
  c1 = [(width - except_tb.x)/2, 0, -inf];
  r1 = [for (dx=[0, except_tb.x], dy=[-inf, thick+inf]) 
          c1 + [dx,dy,0]];
  
  c2 = c1 + [except_tb.y, 0, except_tb.y+inf];
  r2 = [for (dx=[0, except_tb.x - 2*except_tb.y], dy=[-inf, thick+inf]) 
          c2 + [dx,dy,0]];
  
  make_hull(concat(r1, r2));
  
  translate([0, 0, height])
  mirror([0,0,1])
  make_hull(concat(r1, r2));
}

module base_plate () {
  difference () {
    cube([width, thick, height]);
    
    make_holes();

    remove_material_lr();
    remove_material_tb();
  }
}

module connection () {
  c1 = [(width - connection.x) / 2, 0, (height - connection.y) / 2];
  r1 = [for (dx=[0,connection.x], dz=[0,connection.y]) c1 + [dx,0,dz]];
  r2 = [for (pt = r1) pt + delta + [0, thick, 0]];
  make_hull(concat(r1, r2));
}

base_plate();

translate(delta)
base_plate();

connection();
