// Creates a list of integers.

function range(r) = [for (x = r) x];

// Reverses a list.
    
function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];
  
// Concatenates two lists. If either of them is `undef`, it is ignored.

function concat_undef(list1, list2) =
    concat(is_undef(list1) ? [] : list1, is_undef(list2) ? [] : list2);

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
