module u_profile (length, cross, thick) {
  difference () {
    cube([length, cross.x + 2 * thick, cross.y + thick]);
    
    translate([-1, thick, thick])
    cube([length + 2, cross.x, cross.y + 1]);
  }
}

module u_tube_holder (length, cross, thick) {
  difference () {
    union () {
      translate([0, cross.x + 2 * thick, cross.y + thick])
      rotate(180, [1,0,0])
      u_profile(length, cross, thick);
      
      translate([0, 0, cross.y + thick])
      cube([length, cross.x + 2 * thick, 1.6 * cross.x]);
    }
    
    dist = (length - 5 * 4) / 6;
    ofsl = dist + 2;
    
    for (i = [0:4]) {
      #translate([ofsl + i * (dist + 4), 0, 1.6 * cross.y + thick/2])
      rotate(-60, [1,0,0])
      translate([0, 0, -cross.x/2])
      cylinder(cross.x * 3, 2.5, 2.5, $fn = 50);
    }
  }
}

u_tube_holder(59, [10.5, 6], 3);

//translate([0, 30, 0])
//u_profile(59, [10.5, 6], 0.5);
