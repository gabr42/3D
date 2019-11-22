width = 20;
length = 80;
length_tab = 15;
width_tab = 10;
angle_len = 40;
thick = 6;
thick_tab = 4;
space = 0.1;
hole = 3;

taper_len = 3;
taper_d = 1;

num_support = 1;

module side () {
  cube([length, width, thick]);

  translate([length, 0, 0])
  hull () {
    cube([length_tab - taper_len, width, thick_tab]);
    
    translate([length_tab - taper_len, taper_d, 0])
    cube([taper_len, width - 2 * taper_d, thick_tab - taper_d]);
  }
}

module support () {
  side();

  rotate(90, [0,1,0])
  mirror([1,0,0])
  side();

  translate([0, thick + (width-thick)/2, 0])
  rotate(90, [1,0,0])
  linear_extrude(thick)
  polygon([
    [0, 0], [0,angle_len], [angle_len, 0]
  ]);
}

module hole_tab () {
  difference () {
    cube([length_tab, width_tab, thick_tab]);
    
    translate([length_tab/2, width_tab/2, -thick_tab/2])
    linear_extrude(thick_tab * 2)
    circle(d = hole, $fn=50);
  }
}

module lock () {
  translate([2 * thick_tab + space, 0, 0])
  rotate(-90, [0, 1, 0])
  translate([0, -2 * width, 0]) {
    translate([0, -thick_tab, 0])
    cube([length_tab, thick_tab, 2 * thick_tab + space]);

    translate([0, - width_tab - thick_tab, 0])
    hole_tab();  

    translate([0, 0, thick_tab + space])
    cube([length_tab, width + space, thick_tab]);
    
    translate([0, width + space, 0])
    cube([length_tab, thick_tab, 2 * thick_tab + space]);

    translate([0, width + thick_tab + space, 0])
    hole_tab();
  }
}

module make_supports () {
  for (i = [1:num_support]) {
    translate([0, (i-1) * width * 1.5, 0])
    support();
    
    translate([(i-1) * 6 * thick_tab, 0, 0]) {
      lock();
      
      translate([3 * thick_tab, 0, 0])
      lock();
    }
  }
}

for_real = false;

if (for_real)
  make_supports();
else {
  // test print
  
  translate([-length + 10, 0, 0])
  difference () {
    support();
   
    translate([-1, -width/2, -thick/2])
    cube([length - 10 + 1, width * 2, length * 2]);
  }

  lock();
}