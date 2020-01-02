// Creates a list of integers.

function range(r) = [for (x = r) x];

// Slices a list.

function slice(list, range) = [for (i = range) list[i]];

// Returns last element in a list.

function last(list) = list[len(list)-1];

// Checks whether a list contains an element.

function contains(el, list) = len(search(el, list)) > 0;

// Reverses a list.
    
function reverse(list) = slice(list, [len(list)-1:-1:0]);

// Replaces one element in a list.

function replace(list, index, value) = 
  index == 0
    ? concat([value], slice(list, [1:len(list)-1]))
    : index == len(list)-1
      ? concat(slice(list, [0:len(list)-2]), [value])
      : concat(slice(list, [0:index-1]), [value], slice(list, [index+1:len(list)-1]));

// From the first lists selects the first element where the corresponding
// element in the second list is not zero.

function select(values, selector, pos) = 
  let(pos = is_undef(pos) ? 0 : pos)
  selector[pos] != 0 
    ? values[pos]
    : select(values, selector, pos+1);

// Keep all values from the values list where corresponding selector is 0
// and replace all other values with the values from the new_values list.

function select_replace(values, selector, new_values) = 
  [for (i = [0:len(values)-1]) selector[i] == 0 ? values[i] : new_values[i]];

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