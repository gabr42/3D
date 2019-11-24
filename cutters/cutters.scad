use <../lib/helpers.math.scad>

cutter_height = 13;
cutter_dtop = 0.4;
cutter_dbottom = 2.5;

cutter_delta_preview = 0.5;
cutter_delta_release = 0.05;

//cutter_release = true;
//cutter_verbose = true;

function cutter_is_verbose() =
  is_undef(cutter_verbose) ? false : cutter_verbose;

function cutter_delta() =
  is_undef(cutter_release) 
     ? cutter_delta_preview 
     : cutter_release ? cutter_delta_release : cutter_delta_preview;

module cutter_render () {
  $cutter_num_layers = floor((cutter_dbottom - cutter_dtop) / cutter_delta());
  hd = cutter_height/$cutter_num_layers;

  if (cutter_is_verbose()) {
    echo(str("Number of layers: ", $cutter_num_layers));
    echo(str("Layer height: ", hd));
  }
  
  for ($cutter_layer = [0:$cutter_num_layers-1]) {
    $cutter_layer_thickness =  cutter_dbottom + $cutter_layer * (cutter_dtop - cutter_dbottom) / ($cutter_num_layers - 1);

    if (cutter_is_verbose()) 
      echo(str("Layer ", $cutter_layer, " thickness: ", $cutter_layer_thickness));

    translate([0, 0, $cutter_layer*hd])
    linear_extrude(hd)
    children();
  }
}

module cutter_wall (thickness) {
  difference () {
    offset(delta=thickness)
    children();

    children();
  }
}
