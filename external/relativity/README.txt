                   .:                     :,                                          
,:::::::: ::`      :::                   :::                                          
,:::::::: ::`      :::                   :::                                          
.,,:::,,, ::`.:,   ... .. .:,     .:. ..`... ..`   ..   .:,    .. ::  .::,     .:,`   
   ,::    :::::::  ::, :::::::  `:::::::.,:: :::  ::: .::::::  ::::: ::::::  .::::::  
   ,::    :::::::: ::, :::::::: ::::::::.,:: :::  ::: :::,:::, ::::: ::::::, :::::::: 
   ,::    :::  ::: ::, :::  :::`::.  :::.,::  ::,`::`:::   ::: :::  `::,`   :::   ::: 
   ,::    ::.  ::: ::, ::`  :::.::    ::.,::  :::::: ::::::::: ::`   :::::: ::::::::: 
   ,::    ::.  ::: ::, ::`  :::.::    ::.,::  .::::: ::::::::: ::`    ::::::::::::::: 
   ,::    ::.  ::: ::, ::`  ::: ::: `:::.,::   ::::  :::`  ,,, ::`  .::  :::.::.  ,,, 
   ,::    ::.  ::: ::, ::`  ::: ::::::::.,::   ::::   :::::::` ::`   ::::::: :::::::. 
   ,::    ::.  ::: ::, ::`  :::  :::::::`,::    ::.    :::::`  ::`   ::::::   :::::.  
                                ::,  ,::                               ``             
                                ::::::::                                              
                                 ::::::                                               
                                  `,,`


http://www.thingiverse.com/thing:349943
The Openscad General Library of Relativity by 16807 is licensed under the GNU - GPL license.
http://creativecommons.org/licenses/GPL/2.0/

# Summary

[Wiki](https://github.com/davidson16807/relativity.scad/wiki)  
[Repo](https://github.com/davidson16807/relativity.scad)  
   
This OpenSCAD library adds functionality to size, position, and orient objects relative to other geometric primitives.   
 
To do so, the library introduces a new set of modules to replace the default geometric primitives in OpenSCAD. These new primitives have the ability to center themselves along any axis, and place their children along any border.   
   
So this:  
   
	cube_h=10;  
	cylinder_d=7;  
	translate([0,0,cube_h/2]){  
		cube(cube_h, center=true);  
	  
		translate([cube_h/2 + cylinder_d/2,0,0])  
		cylinder(d=cylinder_d, h=cube_h, center=true);  
	}  
   
becomes this:  
   
	box(10, anchor=[0,0,-1])  
	align([1,0,0])  
	rod(d=7, h=$parent_size.z);  
   
But the library does more. *Way* more. The library does for OpenSCAD what css does for html. 

*It seperates presentation from content.*

You can build a single module that renders every part of a project as it appears assembled, then create a presentation layer to isolate a printable part using [show](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#show) or [hide](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#hide). You can go the opposite way, too - you can define a series of components, then define attachment points for each and use [attach](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#attach) to pop them into place like lego blocks. Similar [modules](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations) exist for every CSG operation. The modules work with [selectors](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#selectors) to specify the primitives you want to work with, much like [css](http://www.w3schools.com/cssref/css_selectors.asp) or [jquery](http://www.w3schools.com/jquery/jquery_ref_selectors.asp):

    //OpenSCAD logo:  
    differed("hole")  
    ball(50)  
    orient([x,y,z])  
    rod(d=25, h=50, $class="hole");  
   
For more information, check out the [wiki](https://github.com/davidson16807/relativity.scad/wiki)!  
   
##Updates  
**1/25/16** Took down the link to the 2014.03 compatible version, since it was causing confusion. 

**11/26/15** Added new CSS-like operations: `colored()`, `resized()`, and `scaled()`. Also, fixed an issue causing selectors to not correctly interpret parent-child relationships.

**3/17/15**: relativity.scad has been updated to make use of new functionality in the 2015.03 version of OpenSCAD. **relativity.scad is no longer compatible with OpenSCAD version 2014.03.** If you wish to continue using 2014.03, the older version of relativity.scad is still available under the Downloads section as "[relativity.2014.03.scad](http://www.thingiverse.com/download:1168738)"   
   
**2/14/15**: Implemented support for parent/child and ancestor/descendant relationships in the selector engine. Selectors now enforce whitespace sensitivity. A useful new module has been added, [attach()](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#attach). This module allows you to invoke the `children()` operator multiple times throughout a module, then specify which instance of `children()` you want to attach to. There is [a new demo](https://github.com/davidson16807/relativity.scad/wiki/Motor-Mount)  on the wiki that demonstrates this functionality  
   
**1/19/15**: CSG operations can now be assigned a value for `$class`. This enables them to be used by other CSG operations higher up the call stack. `differed()` now accepts `positive` as an optional parameter that defaults to the opposite of negative. Two selector based operations have been introduced, `show()` and `hide()`, with obvious functionality.  

**12/25/14**: Relativity now borrows code from the [String Theory](http://www.thingiverse.com/thing:526023) library. This enables advanced class selectors in CSG operations such as negation and class union, e.g. `hulled("not(foo)")` or `hide("this,that")`. Syntax for these operations are intended to match documentation for [existing standards](http://www.w3schools.com/jquery/jquery_ref_selectors.asp) used in web development. Details are available on the [wiki](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations#selectors)   

**10/31/14**: `construct` has been renamed to `differed`, which now works through a `$class` parameter much like the `class` attribute of html. Other modules similar to `construct` have been added, including `hulled` and `intersected`. Two new parameters were added, `$inward` and `$outward`, which represent vectors towards and away from the center of the parent object. The `anchor` parameter now defaults to `$inward`. Miscellaneous functions such as `mill` and `slice` are now depreciated. Check the [wiki](https://github.com/davidson16807/relativity.scad/wiki/CSG-operations) for more details.   
   
**9/7/14**: Attempts to align objects to parents of indeterminate size will result in no translation having occurred. This is to address situations where objects would accidentally become lost from sight.  Moved morphological functions to a secondary file, morphology.scad. Added a very useful new function, [construct](https://github.com/davidson16807/relativity.scad/wiki/construct)  
   
**8/23/14**: Diameter and height parameters for rod default to `indeterminate`  
   
**8/20/14**: The `visible` parameter within geometric primitives has been replaced by a special variable, `$show`. The use of a special variable makes it much easier to use existing complex geometries as place holders when positioning other objects. `$show` is chosen over `$visible` as I find the variable is used frequently enough to require shortening the length of its name.  
   
**8/18/14**: Addressed some issues resulting from the interaction of `box`, `rod`, and `orientation`. Parameters for `mill()` have been modified to better express through holes and to allow specification for the direction of cut.  
   
**7/24/14**: added `orientation` parameter to geometric primitives, simplifying situations where you need to rotate cylinders without disturbing the rotation of their children.  
   

# Instructions

Place relativity.scad in your local OpenSCAD folder under /libraries On Windows, this folder should default to Documents/OpenSCAD/libraries.   
Import relativity.scad with the following line of code:  
    include <relativity.scad>  
For full documentation, check out the up and coming wiki: https://github.com/davidson16807/relativity.scad/wiki