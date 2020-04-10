// Constants

e = 2.71828;
tau = (1 + sqrt(5)) / 2;
inf = 0.01;

// is_defined

function is_defined(value) = !is_undef(value);

// Logistic function and its derivative.

function logistic_function(x) = 
  let (ex = exp(x))
  ex / (ex + 1);

function logistic_function_dx(x) = 
  let (ex = exp(x))
  ex / ((ex + 1)*(ex + 1));
  
// Calculates length of a vector.

function length(v) = norm(v);

// Normalizes a vector.

function normalize(v) = v / length(v);

// Calculates hypothenuse of right triangle from its sides.

function hypoth(a, b) = sqrt(pow(a, 2) + pow(b, 2));

// Angle between two vectors.

function angle3(u, v = [1,0,0]) = 
  atan2(norm(cross(u, v)), u * v);

// Given a 2D directional vector, turns 90 deg CW and returns new vector.

function turn_right(xy) = [xy.y, -xy.x];

// Given a 2D directional vector, turns 90 deg CCW and returns new vector.

function turn_left(xy) = [-xy.y, xy.x];

// Returns original value (if not undef) or provided default (if the value is undef).

function initialize(value, default) =
  is_undef(value) ? default : value;

// Returns even/odd status of a number.

function even(num) = num % 2 == 0;

function odd(num) = num % 2 == 1;
