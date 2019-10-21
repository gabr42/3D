// Translates all points in a list by a specified offset.
// Supports 2D and 3D points. Supports 2D and 3D offsets.
// Offsetting a 2D point in 3 dimension creates a 3D point. Starting z is assumed to be 0.

function translate(points, offset) = 
  [for (i = points) is_undef(offset.z) ? [i.x + offset.x, i.y + offset.y] :
    [i.x + offset.x, i.y + offset.y, is_undef(i.z) ? offset.z : i.z + offset.z]];

// Creates a list of integers.

function make_list(from, to) = 
  [for (i = [from:to]) i];

// Reverses a list.
    
function reverse(list) = 
  [for (i = [len(list)-1:-1:0]) list[i]];
