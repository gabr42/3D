use <../lib/helpers.lists.scad>
use <../lib/helpers.math.scad>
use <../lib/helpers.objects.scad>
use <../lib/geometry.scad>

function l_create(__pos, __next, __dir, __spacing, __baseline, __max_stretch) = 
//  echo("Pos: ", __pos, ", Next: ", __next, ", Dir: ", __dir, ", Spacing: ", __spacing, ", Baseline: ", __baseline, ", Max stretch: ", __max_stretch)
  [__pos, __next, __dir, __spacing, __baseline, __max_stretch];

function l_str(layout) = 
  str("Pos: ", l_pos(layout), 
       ", Next: ", l_next(layout), 
       ", Dir: ", l_dir(layout), 
       ", Spacing: ", l_spacing(layout), 
       ", Baseline: ", l_baseline(layout), 
       ", Max stretch: ", l_max_stretch(layout));

function l_pos(layout, __pos) =  __getset(layout, 0, __pos);
function l_next(layout, __next) = __getset(layout, 1, __next);
function l_dir(layout, __dir) = __getset(layout, 2, __dir);
function l_spacing(layout, __spacing) = __getset(layout, 3, __spacing);
function l_baseline(layout, __baseline) = __getset(layout, 4, __baseline);
function l_max_stretch(layout, __max_stretch) = __getset(layout, 5, __max_stretch);

function layout_init(dir, spacing, max_stretch) = 
  l_create([0,0,0], [0,0,0], dir, spacing, 0, max_stretch);

function make_right_layout(spacing, max_row_width) = 
  layout_init([1,0], spacing, max_row_width);

function make_up_layout(spacing, max_col_height) = 
  layout_init([0,1], spacing, max_col_height);

function layout_advance(layout, bb) =
  let(l_spc = l_spacing(layout),
      dir = l_dir(layout),
      base = l_baseline(layout),
      reposition = [base - bb_left(bb), base - bb_bottom(bb)],
      spacing = mul_lists([l_spc, l_spc], dir),
      offset = make_3D(mul_lists([bb_width(bb), bb_height(bb)], dir) + spacing),
      next = l_next(layout) + offset)
  echo([bb_width(bb), bb_height(bb)], reposition)
  l_next(l_pos(layout, l_next(layout) + mul_lists([dir.y, dir.x], reposition)), next);

module make (sizes, layout, pos) {
  pos = is_undef(pos) ? 0 : pos;
  if (pos < len(sizes)) {
    size = sizes[pos];
    
//    new_layout = layout_advance(layout, bb_create([-size/2, -size/2], [size/2, size/2]));
    new_layout = layout_advance(layout, bb_create([0, 0], [size, size]));
    echo(l_str(new_layout));

    translate(new_layout[0])
//    cube([size, size, size], center = true);
    cube([size, size, size]);
        
    make(sizes, new_layout, pos+1);
  }
}

make([2,4,6,4,2], make_right_layout(2));
//make([2,4,6,4,2], make_up_layout(2));
