
// [Global]

// diameter of the template arc [mm]
Arc_radius = 50;

// angle of the template arc [deg]
Arc_angle = 90; //[5:180]

Outside_arc = true;

/* [Label] */

// enable to label the radius
Show_label = true;

// custom label text
Override_text = "";

// enable to label the arc angle
Show_angle = false;

// custom angle text
Override_angle = "";

Font_size = 9;

Font_name = "Liberation Sans:Bold";

/* [More] */

// template width [mm]
Width = 20;

// template thickness [mm]
Thickness = 5;

// length of linear arms [mm]
Linear_arm_length = 30;

// height of the guide [mm]
Guide_height = 6;

// width of the guide [mm]
Guide_width = 10;

// depth of the label [mm]
Label_depth = 1;

/* [Fine tuning] */

$fn = 200;
$fa = 1;
Small_chamfer = 0.25;
Undercut = 0.25;
Overlap = 0.01;

module __End_Customization__ () {} 

innerArcR = Outside_arc ? Arc_radius - Width : Arc_radius;
outerArcR = innerArcR + Width;

/* main */

make_template();

/* geometry */

function clip0(value) = value > 0 ? value : 0;

function make_chamfered_profile(size, offset, chamfer) =
  [[clip0(offset + chamfer), 0], [offset + size.x - chamfer, 0],
   [offset + size.x, chamfer], [offset + size.x, size.y - chamfer],
   [offset + size.x - chamfer, size.y],
   [clip0(offset + chamfer), size.y],
   [clip0(offset), size.y - chamfer],
   [clip0(offset), chamfer]];  

module qcylinder_neg(r, h, chamfer = 0) {
  difference () {
    cube([r, r, h]);
    
    translate([0, 0, -1])
    cylinder(h = h+2, r = r - chamfer);

    if (chamfer > 0) {
      for (dz = [0:1])
        translate([0, 0, dz*(h) - chamfer])
        rotate_extrude(angle = 90)
        translate([r - chamfer, 0, -chamfer])
        rotate(45)
        square([chamfer*1.4142, chamfer*1.4142]);
      }
  }
}

module qcylinder(r, h, chamfer = 0) {
  difference () {
    cylinder(h = h, r = r);

    translate([r, 0, 0])
    cube([2*r, 2*r, 3*h], center = true);

    translate([0, r, 0])
    cube([2*r, 2*r, 3*h], center = true);
    
    if (chamfer > 0) {
      for (dz = [0:1])
        rotate(180)
        translate([0, 0, dz*(h) - chamfer])
        rotate_extrude(angle = 90)
        translate([r, 0, -chamfer])
        rotate(45)
        square([chamfer*1.4142, chamfer*1.4142]);
      }
  }
}
 
/* modules */

module make_template() {
  difference () {
    union () {
      rotate_extrude(angle = Arc_angle)
      polygon(make_chamfered_profile([Width, Thickness], innerArcR, Small_chamfer));
    
      if (innerArcR <= Thickness) {
        d = Thickness - Thickness * cos(Arc_angle/2);  
        translate([0, 0, 0])
        make_template_inner_fillet();
      }
      
      make_guide();

      rotate(Arc_angle)
      mirror([0,1,0])
      make_guide();
    }

    if (Show_label)
      rotate(Arc_angle)
      translate([Width/2 + innerArcR, Linear_arm_length/2, Thickness - Label_depth])
      linear_extrude(2*Label_depth)
      rotate(-90)
      make_label(Override_text == "" ? str(Arc_radius) : Override_text);

    if (Show_angle) 
      translate([Width/2 + innerArcR, -Linear_arm_length/2, Thickness - Label_depth])
      linear_extrude(2*Label_depth)
      rotate(-90)
      make_label(Override_angle == "" ? str(str(Arc_angle), "\u00B0") : Override_angle);
  }
}

module make_template_inner_fillet() { 
  beta = (180 - Arc_angle)/2;
  _r = Thickness / cos(beta);
  _x = tan(90-Arc_angle) * (_r - _r * cos(Arc_angle));
  fac = -_x > Width ? -_x/Width : 1;
  r = _r/fac;
  x = tan(90-Arc_angle) * (r * (1 -  cos(Arc_angle)));
  
  translate([-r + innerArcR, (-r*sin(Arc_angle) + x) + innerArcR * tan(Arc_angle/2), 0])
  rotate(0*-Arc_angle/2)
  rotate_extrude(angle = Arc_angle)
  polygon(make_chamfered_profile([Width*0.9, Thickness], r, Small_chamfer));  
}

module make_guide() {
  translate([innerArcR, 0, 0]) {
    union () {
      difference () {
        make_chamfered_arm();
       
        translate([Outside_arc ? -1 - Overlap : Width - Thickness + Overlap, -Linear_arm_length - 1 - Overlap, -1])
        cube([Thickness+1, Thickness+1, Thickness+2]);
      }
      
      translate([Outside_arc ? Thickness : Width - Thickness, -Linear_arm_length + Thickness, 0])
      mirror([Outside_arc ? 0 : 1,0,0]) 
      qcylinder(h = Thickness, r = Thickness, chamfer = Small_chamfer);
    }
    
    make_guide_tab();
    make_guide_outer_fillet();
    make_guide_inner_fillet();
  }
}

module make_chamfered_arm() {
  difference () {
    translate([0, Overlap, 0])
    rotate(90, v=[1,0,0])
    linear_extrude(Linear_arm_length + Overlap)
    polygon(make_chamfered_profile([Width, Thickness], 0, Small_chamfer));
    
    translate([-1, -Linear_arm_length, -Small_chamfer + Thickness])
    rotate(45, [1,0,0])
    cube([Width + 2, Small_chamfer*1.4142, Small_chamfer*1.4142]);    
    
    translate([-1, -Linear_arm_length, -Small_chamfer])
    rotate(45, [1,0,0])
    cube([Width + 2, Small_chamfer*1.4142, Small_chamfer*1.4142]);
  }
}

module make_guide_tab() {
  translate([Outside_arc ? Width + Thickness : - Thickness, 0, 0])
  translate([0, - Linear_arm_length, Thickness])
  mirror([Outside_arc ? 1 : 0,0,0]) 
  union () {
    difference () {
      linear_extrude(Guide_height)
      polygon(make_chamfered_profile([Thickness, Guide_width], 0, Small_chamfer));
      
      translate([Thickness - Undercut*1.4142/2, -Guide_width/2, 0])
      rotate(45, v=[0,1,0])
      cube([Undercut, 2*Guide_width, Undercut]);

      for (dx = [0:1])
      translate([dx*Thickness - Small_chamfer, 0, Guide_height])
      rotate(45, [0,1,0])
      translate([0, -Guide_width/2, 0])
      cube([Small_chamfer*1.4142, Guide_width*2, Small_chamfer*1.4142]);
      
      for (dy = [0:1])
      translate([0, dy*Guide_width, Guide_height - Small_chamfer])
      rotate(45, [1,0,0])
      translate([-Guide_width/2, 0, 0])
      cube([Guide_width*2, Small_chamfer*1.4142, Small_chamfer*1.4142]);
    }
  }
}

module make_guide_outer_fillet() {
  translate([Outside_arc ? Width : 0, - Linear_arm_length + Guide_width, Thickness])
  mirror([Outside_arc ? 1 : 0,0,0])
  rotate(90, v=[1,0,0]) 
  union () {
    rotate(-90, [0,1,0])
    rotate(180, [1,0,0])
    linear_extrude(Small_chamfer)
    polygon(make_chamfered_profile([Guide_width, Thickness], 0, Small_chamfer));
    difference() {
      qcylinder(h = Guide_width, r = Thickness, chamfer = Small_chamfer);

      for (dz = [0:1])
      translate([-Undercut, -Small_chamfer, dz*(Guide_width) + Small_chamfer])
      rotate(90, [0,1,0])
      linear_extrude(Undercut)
      polygon([[0, Small_chamfer], [Small_chamfer, Small_chamfer], [Small_chamfer, 0]]);
    }    
  }
}

module make_guide_inner_fillet() {
  difference () {
    inFillet = Thickness - 2*Small_chamfer;
    translate([(Outside_arc ? Width : 0), - Linear_arm_length + Guide_width + inFillet - Small_chamfer, Small_chamfer])
    mirror([Outside_arc ? 1 : 0,0,0])
    translate([-inFillet + Small_chamfer, 0, 0])
    rotate(-90)
    qcylinder_neg(r = inFillet, h = inFillet);

    translate([(Outside_arc ? Width : 0), - Linear_arm_length + Guide_width*1.5, Thickness])
    mirror([Outside_arc ? 1 : 0,0,0])
    rotate(90, [1, 0, 0])
    rotate(180)
    qcylinder_neg(r = Thickness, h = Guide_width);
      }
}

module make_label (text) {
  text(text, font = Font_name, size=Font_size, halign="center", valign="center");
}