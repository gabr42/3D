use <../lib/helpers.lists.scad>
use <../lib/helpers.math.scad>
use <../lib/helpers.objects.scad>
use <../lib/geometry.scad>

function l_create(__pos, __next, __dir, __spacing, __baseline, __max_stretch, __cur_stretch) = 
//  echo("Pos: ", __pos, ", Next: ", __next, ", Dir: ", __dir, ", Spacing: ", __spacing, ", Baseline: ", __baseline, ", Max stretch: ", __max_stretch)
  [__pos, __next, __dir, __spacing, __baseline, __max_stretch, __cur_stretch];

function l_str(layout) = 
  str("Pos: ", l_pos(layout), 
       ", Next: ", l_next(layout), 
       ", Dir: ", l_dir(layout), 
       ", Spacing: ", l_spacing(layout), 
       ", Baseline: ", l_baseline(layout), 
       ", Max stretch: ", l_max_stretch(layout),
       ", Current stretch: ", l_cur_stretch(layout));

function l_pos(layout, __pos) =  __getset(layout, 0, __pos);
function l_next(layout, __next) = __getset(layout, 1, __next);
function l_dir(layout, __dir) = __getset(layout, 2, __dir);
function l_spacing(layout, __spacing) = __getset(layout, 3, __spacing);
function l_baseline(layout, __baseline) = __getset(layout, 4, __baseline);
function l_max_stretch(layout, __max_stretch) = __getset(layout, 5, __max_stretch);
function l_cur_stretch(layout, __cur_stretch) = __getset(layout, 6, __cur_stretch);

function layout_init(dir, spacing, max_stretch) = 
  l_create([0,0,0], [0,0,0], dir, spacing, 0, max_stretch, [0,0]);

function make_right_layout(spacing, max_width) = 
  layout_init([1,0], spacing, max_width);

function make_up_layout(spacing, max_height) = 
  layout_init([0,1], spacing, max_height);

function wrap(layout, stretch, new_baseline) = // [new_baseline, new_cur_stretch, new_next]
  let (maxs = l_max_stretch(layout),
       do_wrap = !is_undef(maxs) && stretch >= maxs)
//  echo(maxs, stretch, do_wrap)
  [ do_wrap ? new_baseline + l_spacing(layout)
            : l_baseline(layout),
    do_wrap ? [0,0]
            : l_cur_stretch(layout),
    do_wrap ? select_replace(l_next(layout), make_3D(l_dir(layout)), [0,0,0])
            : l_next(layout)
  ];

function layout_advance(layout, bb) =
  let(l_spc = l_spacing(layout),
      dir = l_dir(layout),
      base = l_baseline(layout),
      reposition = mul_lists([base, base], [dir.y, dir.x]) - [bb_left(bb), bb_bottom(bb)],
      spacing = mul_lists([l_spc, l_spc], dir),
      offset = make_3D(mul_lists([bb_width(bb), bb_height(bb)], dir) + spacing),
      next = l_next(layout) + offset,
      new_pos = l_pos(layout, l_next(layout) +  reposition),
      new_next = l_next(new_pos, next),
      stretch = dir.x == 1 ? max(l_cur_stretch(new_next).y, base + bb_height(bb)) : max(l_cur_stretch(new_next).x, base_bb_width(bb)),
      l3 = l_cur_stretch(new_next, dir.x == 1 ? [next.x, stretch]: [stretch, next.y]),
      w = wrap(l3, select(l_cur_stretch(l3), dir), stretch),
      new_base = l_baseline(l3, w[0]),
      l5 = l_cur_stretch(new_base, w[1]),
      l6 = l_next(l5, w[2]))
  echo("Base", base, "Reposition", reposition)
  l6;

module make (sizes, layout, pos) {
  pos = is_undef(pos) ? 0 : pos;
  if (pos < len(sizes)) {
    size = sizes[pos];

    echo("Size", size);
    
    new_layout = layout_advance(layout, bb_create([-size/2, -size/2], [size/2, size/2]));
//    new_layout = layout_advance(layout, bb_create([0, 0], [size, size]));
    echo(l_str(new_layout));

    translate(new_layout[0])
    cube([size, size, size], center = true);
//    cube([size, size, size]);
        
    make(sizes, new_layout, pos+1);
  }
}

make([for (i=[1:3]) each [2,4,6,4,2]], make_right_layout(2, max_width = 25));
//make([2,4,6,4,2], make_up_layout(2));
