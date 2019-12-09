heart(20+2, 10, 2);

// based on https://www.revk.uk/2017/02/opnescad-with-some-heart.html

module heart(width, H, wall = 0, half = false) {
  W = width / 65.23 * 40;
  L = width / 65.23 * 80;
  A = atan2(W, L - W);

  if (wall == 0)
    solid_heart(W, L, A, H, 0, 0, half);
  else {
    difference () {
      solid_heart(W, L, A, H, wall, wall * 2, half);
      solid_heart(W, L, A, H, wall * 2, wall, half);
    }
  } 
}

module solid_heart(W, L, A, H, dh, dv, half) {
  rotate([0, 0, A])
  solid_half(W, L, A, H, dh, dv, half);
  
  mirror([1, 0, 0])
  rotate([0, 0, A])
  solid_half(W, L, A, H, dh, dv, half);
}


module solid_half(W, L, A, H, dh, dv, half) {
  difference ()
  {
    hull () {
      translate([0, (L-W)/2, 0])
      sphere(d = W - dh*2);
      
      translate([0, (W-L)/2, 0])
      sphere(d = W - dh*2);
    }

    translate([-L, -L, H/2 - dv])
    cube([L*2, L*2, W]);
    
    translate([-L, -L, -H/2 - W + dv])
    cube([L*2, L*2, W]);
    
    rotate([0, 0, A])
    translate([-L/2, -L + (half ? dh : -0.01), -H])
    cube([L, L, H*2]);
  }
}

