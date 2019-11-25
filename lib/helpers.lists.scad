// Creates a list of integers.

function range(r) = [for (x = r) x];

// Slices a list.

function slice(list, range) = [for (i = range) each list[i]];

// Reverses a list.
    
function reverse(list) = slice(list, [len(list)-1:-1:0]);

// Concatenates two lists. If either of them is `undef`, it is ignored.

function concat_ifdef(list1, list2) =
  is_undef(list1) 
    ? list2
    : is_undef(list2)
        ? list1
        : concat(list1, list2);

// Quicksort
// http://forum.openscad.org/OpenJSCAD-our-javascript-friends-td7835.html

function quicksort(list) = !(len(list)>0) ? [] : let( 
    pivot   = list[floor(len(list)/2)], 
    lesser  = [ for (y = list) if (y  < pivot) y ], 
    equal   = [ for (y = list) if (y == pivot) y ], 
    greater = [ for (y = list) if (y  > pivot) y ] 
) concat( 
    quicksort(lesser), equal, quicksort(greater) 
); 

// Returns sum of list elements.

function sum_list(list, idx = 0) =
  len(list) == 0 ? 0
                 :  idx < len(list) - 1 ? list[idx] + sum_list(list, idx + 1)
                                        : list[idx];

// Multiply lists element-wise.

function mul_lists(list1, list2) =
  [for (idx = [0:1:len(list1)-1]) list1[idx] * list2[idx]];

// Checks whether a list is a vector (must contain elements, first element must be a number).

function is_vector(v) = 
  is_list(v) 
  && len(v) > 0 
  && is_num(v[0]);