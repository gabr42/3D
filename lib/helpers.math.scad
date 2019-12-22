// Constants

e = 2.71828;
tau = (1 + sqrt(5)) / 2;
inf = 0.01;

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

function angle(u, v) = 
  let (u3 = make_3D(u),
       v3 = make_3D(v))
  atan2(norm(cross(u3, v3)), u3 * v3);

// Given a 2D directional vector aligned along X or Y, turns 90 deg CW and returns new vector.

function turn_right(xy) = [xy.y, -xy.x];

// Given a 2D directional vector aligned along X or Y, turns 90 deg CCW and returns new vector.

function turn_left(xy) = [-xy.x, xy.y];

// Returns original value (if not undef) or provided default (if the value is undef).

function initialize(value, default) =
  is_undef(value) ? default : value;
