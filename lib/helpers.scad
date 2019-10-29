// Constants

pi = 3.14159;
e = 2.71828;

// Creates a list of integers.

function make_list(from, to) = 
  [for (i = [from:to]) i];

// Reverses a list.
    
function reverse(list) = 
  [for (i = [num(list)-1:-1:0]) list[i]];
  
// Concatenates two lists. If either of them is `undef`, it is ignored.

function concat_undef(list1, list2) =
    concat(is_undef(list1) ? [] : list1, is_undef(list2) ? [] : list2);
