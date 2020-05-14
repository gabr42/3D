support_diameter_mm = 100;

column_diameter_mm = 8;
column_height_mm = 100;
num_columns = 3;

roof_diameter_mm = support_diameter_mm + 2 * 20;
roof_height_mm = 15;
roof_angle = 40;
roof_thickness = 4;

difference () {
  cylinder(d1 = roof_diameter_mm - 2 * (roof_height_mm / tan(roof_angle)), d2 = roof_diameter_mm, h = roof_height_mm, $fa = 1);

  translate([0, 0, roof_thickness])
  cylinder(d1 = roof_diameter_mm - 2 * (roof_height_mm / tan(roof_angle)), d2 = roof_diameter_mm, h = roof_height_mm, $fa = 1);
  
   
}

difference () {
  for (angle = [0:360/num_columns:359])
    rotate(angle)
    translate([support_diameter_mm/2, 0, 0.01]) {
      cylinder(d = column_diameter_mm, h = column_height_mm, $fn = 50);
      
      translate([0, 0, column_height_mm])
      cylinder(d1 = column_diameter_mm, d2 = 0, h = column_diameter_mm, $fn = 50);
    }
  
  difference () {
    cylinder(d = roof_diameter_mm, h = roof_height_mm);
    
    cylinder(d1 = roof_diameter_mm - 2 * (roof_height_mm / tan(roof_angle)), d2 = roof_diameter_mm, h = roof_height_mm, $fa = 1);    
  }
}