use <../lib/helpers.lists.scad>
use <../lib/helpers.math.scad>
use <../lib/geometry.scad>

function __create(__pos, __next, __dir, __bb) = 
  [__pos, __next, __dir, __bb];
function __pos(layout) = layout[0];
function __next(layout) = layout[1];
function __dir(layout) = layout[2];
function __bb(layout) = layout[3];

function layout_init(layout, xy, dir) = 
  is_undef(layout) 
    ? __create([], [0,0,0], dir, xy) 
    : layout;

function layout_advance(layout, spacing, xy) =
  __create(
    __next(layout), 
    __next(layout) + xy + mul_lists([spacing, spacing], __dir(layout)),
    __dir(layout),
    __bb(layout));

function layout_right(layout, spacing, xy) =
  layout_advance(layout_init(layout, [1,0]), spacing, [__bb_width(xy), 0]);

function layout_up(layout, spacing, xy) =
  layout_advance(layout_init(layout, [0,1]), spacing, [0, __bb_height(xy)]);
  
function layout_check_bb(layout, new_pos, xy) = 
  let (dir = __dir(layout),
       bb = __bb(layout),
       //new_dir = (dir.x > 0) && (new_pos.x > dir.x)
       //       || (dir.x < 0) && ((new_pos.x + xy.x) < dir.x)
       //        || (dir.y > 0) && (new_pos.y > dir.y)
       //        || (dir.y < 0) && ((new_pos.y + xy.y) < dir.y)
             
       new_dir = 
         dir.y == 0 
           ? dir.x > 0
               ? new_pos.x > __bb_right(bb)
                   ? [turn_right(dir), __bb_right(bb, new_pos.x + xy.x)]
                   : [dir, bb]
               : (new_pos.x + xy.x) < __bb_left(bb)
                   ? [turn_right(dir), __bb_left(bb, new_pos.x)]
                   : [dir, bb]
           : dir.y > 0
               ? new_pos.y > __bb_top(bb)
                   ? [turn_right(dir), __bb_top(bb, new_pos.y + xy.y)]
                   : [dir, bb]
               : (new_pos.y + xy.y) < __bb_bottom(bb)
                   ? [turn_right(dir), __bb_bottom(bb, new_pos.y)]
                   : [dir, bb])
  [new_dir[0], []]; // new direction, new bb

function layout_spiral(layout, spacing, xy) =
  let(layout = layout_init(layout, xy, [1,0]),
      new_pos = __next(layout) 
                  + mul_lists(xy, __dir(layout)) 
                  + mul_lists([spacing, spacing], __dir(layout)),
      dir_bb = layout_check_bb(layout, new_pos, xy))
  __create(__next(layout), new_pos, dir_bb[0], dir_bb[1]);

module make (sizes, pos, layout) {
  pos = is_undef(pos) ? 0 : pos;
  if (pos < len(sizes)) {
    size = sizes[pos];
    
    new_layout = layout_right(layout, 2, __bb_create(0, 0, size, size));
    echo(new_layout);
    
    translate(new_layout[0])
    cube([size, size, size]);
        
    make(sizes, pos+1, new_layout);
  }
}

make([2,4,6,4,2]);
