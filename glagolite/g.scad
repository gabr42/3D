// LetterBlock.scad - Basic usage of text() and linear_extrude()

use <EUGLAG70.TTF> // https://fonts2u.com/eugens-glagoljica-uglata.font

height_in = 4;
height_out = 5;
cut = 1;

difference() {
  OutlinedG(height_in, height_out, $fn=50);

  translate([-5.5, 5, 0])
  rotate(67)
  translate([0, 0, height_in-cut])
  linear_extrude(height=cut+1) // +1 for visibility in Preview
  LetterBlock("Glagolite d.o.o.", size = 2.5, font="Arial Narrow");

  translate([-2, -2.3, 0])
  rotate(31)
  translate([0, 0, height_in-cut])
  linear_extrude(height=cut+1) // +1 for visibility in Preview
  LetterBlock("katjabg@glagolite.si", size = 2, font="Arial Narrow");
  
  translate([-12.5, 13, -0.1])
  cylinder(height_out, r=1, $fn=50);
}

module OutlinedG(height_in, height_out) {
  font = "Glagoljica uglata";
  size = 30;
    
  union () {
    linear_extrude(height=height_out)
    difference() {
        offset(r=1)
        LetterBlock("g", size, font);
        
        LetterBlock("g", size, font);
    }
   
    linear_extrude(height=height_in)
    LetterBlock("g", size, font);
  }
}


module LetterBlock(letter, size, font) {
    text(letter, 
        size=size,
        font=font,
        halign="center",
        valign="center");
}
