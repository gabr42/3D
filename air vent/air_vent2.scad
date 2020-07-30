cev = 80;
wcev = 4;
lcev = 50;

profil = [120, 80, 182];
wprofil = 2;

ltrans = 50;

slack = 0.8;

module sqcev (x, y, z, wall) {
  linear_extrude(z)
  difference () {
    square([x, y]);
    
    translate([wall, wall])
    square([x - wall*2, y - wall*2]);
  }
}

module profil () {
  sqcev(profil.x, profil.y, profil.z, wprofil);
}

//profil();

out = [cev * 2 + wcev*3, cev + wcev * 2];

module adapter (reduce) {
  hull () {
    translate([reduce, reduce, reduce == 0 ? 0 : -0.1])
    cube([out.x - 2*reduce, out.y - 2*reduce, 0.1]);
    
    translate([0, 0, reduce == 0 ? 0 : 0.1])
    translate([(out.x - profil.x)/2 + reduce + wprofil + slack/2, (out.y - profil.y)/2 + reduce + wprofil + slack/2, ltrans])
    cube([profil.x - 2*wprofil - 2*reduce - slack, profil.y - 2*wprofil - 2*reduce - slack, 0.1]);
  }
  
  translate([0, 0, ltrans])
  hull () {
    translate([0, 0, reduce == 0 ? 0 : -0.1])
    translate([(out.x - profil.x)/2 + reduce + wprofil + slack/2, (out.y - profil.y)/2 + reduce + wprofil + slack/2, 0])
    cube([profil.x - 2*wprofil - 2*reduce - slack, profil.y - 2*wprofil - 2*reduce - slack, 0.1]);

    translate([0, 0, reduce == 0 ? 0 : 0.1])
    translate([(out.x - profil.x)/2 + reduce + wprofil + slack/2, (out.y - profil.y)/2 + reduce + wprofil + slack/2, lcev])
    cube([profil.x - 2*wprofil - 2*reduce - slack, profil.y - 2*wprofil - 2*reduce - slack, 0.1]);
  }
}  

module cev2 () {
  difference () {
    cube([out.x, out.y, lcev]);
    
    translate([cev/2 + wcev, cev/2 + wcev, -1])
    cylinder(d=cev, h=lcev+2);

    translate([out.x - cev/2 - wcev, cev/2 + wcev, -1])
    cylinder(d=cev, h=lcev+2);
  }
  
  translate([0, 0, lcev - 0.01])
  difference () {
    adapter(0);
    adapter(wprofil);
  }
}

cev2();
