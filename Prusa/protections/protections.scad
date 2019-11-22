

module u_profile (length, cross, thick) {
  difference () {
    cube([length, cross.x + 2 * thick, cross.y + thick]);
    
    translate([-1, thick, thick])
    cube([length + 2, cross.x, cross.y + 1]);
  }
}

u_profile(200, [10, 5], 0.5);

translate([0, 20, 0])
u_profile(200, [10, 5], 0.5);

translate([0, 40, 0])
u_profile(160, [10, 5], 0.5);

translate([0, 60, 0])
u_profile(160, [10, 5], 0.5);
