module sword() {
  linear_extrude(height = 0.01)
  polygon([[0,0], [5,0], [5,1], [6,1], [6,5], [0,5]]);
}

$fn = 50;
$fa = 1;

module around() {
  rotate_extrude(angle=360)
  polygon([[0,0], [0, 0.2], [0.05, 0.2], [0.05, 0.1], [0.1, 0.1], [0.1, 0]]);
}

difference() {
  // offset outwards. We wrap minkowski() with render() to save the results of minkowski()
 // render() { 
    minkowski() {
      sword();
      around();
    }
  //}/**/
  // The original shape
  // we extend the original shape in the z-direction to get rid of the shimmering of 
  // co-incident planes
  translate([0, 0, -0.1])
  scale([1, 1, 100])
  sword();
}