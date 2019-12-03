/* Helpers for providing object-line functionality.
*/

use <helpers.lists.scad>;

function __getset(obj, index, value) =
  is_undef(value)
    ? obj[index]
    : replace(obj, index, value);