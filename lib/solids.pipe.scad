module pipe (r, d, h, wall) {
  translate([0, 0, -h]) {
    difference () {
      r = is_undef(r) ? d/2 : r;
      cylinder(r = r + wall, h = h);
      
      translate([0, 0, -0.01])
      cylinder(r = r, h = h + 0.02);
    }
    
    children();
  }
}

module knee (r, d, h, wall, r_out, angle, angle_out = 0) {
  r = is_undef(r) ? d/2 : r;
  rotate(-90, [0, 1, 0])
  translate([- r_out - r, 0, - r_out - r])
  rotate(-angle_out) {
    rotate(90 + angle_out)
    rotate(-90, [0, 1, 0])
    translate([0, - r_out - r, 0])
    rotate_extrude(angle = angle)
    translate([r_out + r, 0, 0])
    difference () { 
      circle(r = r + wall);  
      circle(r);
    }
  
    children();
  }
}

module adapter (r1, r2, d1, d2, h, wall) {
  r1 = is_undef(r1) ? d1/2 : r1;
  r2 = is_undef(r2) ? d2/2 : r2;
  
  translate([0, 0, -h]) {
    difference () {
      cylinder(r1 = r1 + wall, r2 = r2 + wall, h = h);
      
      translate([0, 0, -0.01])
      cylinder(r1 = r1, r2 = r2, h = h + 0.2);
    }
    
    children();
  }
}
