// Constants

e = 2.71828;
inf = 1e-5;

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

// Angle between two vectors.

function angle(u, v) = 
  let (u3 = make_3D(u),
       v3 = make_3D(v))
  atan2(norm(cross(u3, v3)), u3 * v3);
