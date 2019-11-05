// Constants

pi = 3.14159;
e = 2.71828;

// Creates a list of integers.

function range(r) = [for (x = r) x];

// Reverses a list.
    
function reverse(list) = [for (i = [num(list)-1:-1:0]) list[i]];
  
// Concatenates two lists. If either of them is `undef`, it is ignored.

function concat_undef(list1, list2) =
    concat(is_undef(list1) ? [] : list1, is_undef(list2) ? [] : list2);

// rotate as per a, v, but around point pt
// https://stackoverflow.com/a/45826244/4997

module rotate_around(pt, a, v) {
  translate(pt)
  rotate(a, v)
  translate(-pt)
  children();   
}