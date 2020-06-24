$fn = 50;

difference () {
  union () {
    cylinder(d=8.5, h=8);
    
    translate([0, 0, 8])
    cylinder(d1=8.5, d2=5.5, h=3);
  }
  
  union () {
    translate([0, 0, -1])
    cylinder(d=7, h=9.01);
    
    translate([0, 0, 8])
    cylinder(d1=7, d2=4, h=3);
  }
  
  wedge();
}

difference () {
  translate([0, 0, 11])
  cylinder(d1=5.5, d2=5.0, h=5);

  translate([0, 0, 10.9])
  cylinder(d=4, h=5.2);
  
  render() for (i = [0:0.2:5.2])
    translate([0, 0, 11 + i])
    scale([1, 1 + i/10, 1])
    wedge(0.21);
}

dh = 0.03;
s = 4;
a = 780;

translate([0, 0, 16]) {
  difference () {
    difference () {
      cylinder(d=5, h=a*dh);
      
      translate([0, 0, -1])
      cylinder(d=4, h=a*dh + 2);
    }

    render () for(i = [0:s:a])
      translate([0, 0, i*dh])
      rotate(i)
      scale([1, 1.5 + i/180, 1])
      wedge(s*dh + 0.01);

    translate([-5, 0, a * dh - 5 + 0.1])
    cube([5, 5, 5]);
  }
}

module wedge (h = 20) {
  difference () {
    translate([-0, 0, -0.1])
    scale([5, 1, 1])
    cylinder(d=5, h=h, $fn=3);
    
    translate([0, -10, -1])
    cube([20, 20, 22]);
  }
}

module snap (height, wedge_y) {
  difference () {
    cylinder(d=5.5, h=height);
    
    translate([0, 0, -1])
    cylinder(d=4, h=height + 2);

    scale([1, wedge_y, 1])
    wedge ();
  } 
}