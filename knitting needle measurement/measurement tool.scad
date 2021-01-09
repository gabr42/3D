sizes = concat(
          [for(i=[1.5:0.5:6.5]) i],
          [for(i=[7:1:13]) i]);

delta = 5;
slack = 0.4;
thick = 5;
          
function make_offs(sizes, delta, idx = undef, offsets = undef) = 
   is_undef(idx) 
   ? make_offs(sizes, delta, 0, [delta])
   : idx < len(sizes) 
     ? make_offs(sizes, delta, idx+1, 
         concat(offsets,
                offsets[len(offsets)-1] + sizes[idx] + delta))
     : offsets;
          
offsets = make_offs(sizes, delta);
          
width = offsets[len(offsets)-2] + sizes[len(sizes)-1]/2 + delta;          
difference () {
  cube([100, 40, thick]);
 
  for (idx = [0:1:10])
    translate([offsets[idx], 7, -1])
    cylinder(h = 7, d = sizes[idx] + slack, $fn = 50); 

  for (idx = [11:1:len(sizes)-2])
    translate([width - offsets[idx] - 15, 24, -1])
    cylinder(h = 7, d = sizes[idx] + slack, $fn = 50); 
}

write_row(["", "2", "", "3", "", "4", "", "5", "", "6"], 14);

module write_row(labels, y) {
  for (i = [0:1:len(labels)-1]) {
    if (labels[i] != "") {
      write(labels[i], offsets[i], y);
    }
  }
}

write_row2(["12", "11", "10", "9", "8", "7"], 34);

module write_row2(labels, y) {
    //[for(i=[7:1:13]) i]);
  for (i = [11:1:len(sizes)]) {
    if (labels[i] != "") {
      write(labels[len(sizes)-2-i], width - offsets[i] - 15, y);
    }
  }
}

module write(s, x, y) {
  color("red")
  translate([x, y, thick])
  linear_extrude(1.5)
  text(s, 
         size=5,
         font="Calibri:style=Bold",
         halign="center",
         valign="center"); 
}