flange = [152, 82];
flange_out = [18, 10, 18, 18]; // left, top, right, bottom
flange_thick = 2;

mount_fi = 5;
mount_dist = 170;
mount_y = flange.y + flange_out[3] - 37;

out_d = 100;
out_h = 30;
out_thick = 2;
out_dist = 100;

$fn = 150;

cube_out = [flange.x + flange_out[0] + flange_out[2],
            flange.y + flange_out[1] + flange_out[3]];

module flange () {
  difference () {
    cube([cube_out.x, cube_out.y, flange_thick]);
    
    translate([flange_out[0], flange_out[3], -0.05])
    cube([flange.x, flange.y, flange_thick + 0.1]);
    
    hole_left = (cube_out.x - mount_dist)/2;
    translate([hole_left, mount_y, -0.05])
    cylinder(d = mount_fi, h = flange_thick + 0.1);

    translate([hole_left + mount_dist, mount_y, -0.05])
    cylinder(d = mount_fi, h = flange_thick + 0.1);
  }
}

module adapter () {
  difference () {
    hull () {
      translate([flange_out[0] - out_thick,
                 flange_out[3] - out_thick,
                 flange_thick])
      cube([flange.x + 2*out_thick, flange.y + 2*out_thick, 1]);
    
      translate([flange.x/2 + flange_out[0],
                 cube_out.y/2,
                 out_dist])
      cylinder(d = out_d, h = 1);  
    }

    translate([0, 0, -0.01])
    hull () {
      translate([flange_out[0],
                 flange_out[3],
                 flange_thick])
      cube([flange.x, flange.y, 1]);
    
      translate([flange.x/2 + flange_out[0],
                 cube_out.y/2,
                 out_dist])
      cylinder(d = out_d - 2 * out_thick, h = 1.1);  
    }
  }
  
  difference () {
    translate([flange.x/2 + flange_out[0],
              cube_out.y/2,
              out_dist])
    cylinder(d = out_d, h = out_h); 

    translate([flange.x/2 + flange_out[0],
              cube_out.y/2,
              out_dist - 0.5])
    cylinder(d = out_d - 2 * out_thick, h = out_h + 1); 
  }
}

flange();

adapter();