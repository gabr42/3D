// Constants

pi = 3.14159;
e = 2.71828;
inf = 0.00001;

// Creates a list of integers.

function range(r) = [for (x = r) x];

// Reverses a list.
    
function reverse(list) = [for (i = [num(list)-1:-1:0]) list[i]];
  
// Concatenates two lists. If either of them is `undef`, it is ignored.

function concat_undef(list1, list2) =
    concat(is_undef(list1) ? [] : list1, is_undef(list2) ? [] : list2);

// Rotate for angle `a`, around vector `v`, origin in point `pt`.
// https://stackoverflow.com/a/45826244/4997

module rotate_around(pt, a, v) {
  translate(pt)
  rotate(a, v)
  translate(-pt)
  children();   
}

// quicksort
// http://forum.openscad.org/OpenJSCAD-our-javascript-friends-td7835.html

function quicksort(arr) = !(len(arr)>0) ? [] : let( 
    pivot   = arr[floor(len(arr)/2)], 
    lesser  = [ for (y = arr) if (y  < pivot) y ], 
    equal   = [ for (y = arr) if (y == pivot) y ], 
    greater = [ for (y = arr) if (y  > pivot) y ] 
) concat( 
    quicksort(lesser), equal, quicksort(greater) 
); 

// Calculates distance between two 3D points.

function distance(pt1, pt2) =
  sqrt(pow(pt2.x - pt1.x, 2) + pow(pt2.y - pt1.y, 2) + pow(pt2.z - pt1.z, 2));
  
// Linear interpolation betwee two points.

function interpolate(k, pt1, pt2) = 
  [for (i = [0:1:len(pt1)-1]) pt1[i] + (pt2[i] - pt1[i]) * k];
  
// Point on the unit circle corresponding to `angle` (in degrees).
  
function point_on_unit_circle(angle) = [cos(angle), sin(angle)];
