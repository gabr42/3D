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


http://www.thingiverse.com/thing:370871
Fibonacci Sphere: A Smoother Sphere for OpenSCAD by 16807 is licensed under the Creative Commons - Attribution - Share Alike license.
http://creativecommons.org/licenses/by-sa/3.0/

# Summary

##What it is:  
A [fibonacci sphere](http://onlinelibrary.wiley.com/doi/10.1256/qj.05.227/pdf) is an approximation for a sphere that is formed from an arbitrary number of roughly equidistant vertices. Pass it any positive number and you'll get a mesh back containing that exact number of vertices for each hemisphere. All vertices in the sphere will be roughly equidistant.   
   
##What this means to you:  
* You get a sphere model that looks better while using fewer vertices.   
* You have precise control over the number of vertices used.  
* In theory, this also allows `minkowski()` to deliver smoother renders in the same amount of time.  
  
##How it works:  
Vertices start out at the meridian and are spaced at regular intervals along the z axis. With that, each vertex is rotated away from its predecessor by a certain angle. That angle is 360 degrees divided by the [golden ratio](http://en.wikipedia.org/wiki/Golden_ratio).   
For those who want a gentle (and fascinating) introduction as to *why* this algorithm works, try [here](www.youtube.com/watch?v=lOIP_Z_-0Hs)  
   
##Updates:  
5/1/14: Adopted use of list comprehensions. Spheres render so fast, it's bananas - a 10000 vertex sphere takes only a second to render. It previously took 14 minutes. **OpenSCAD version 2015.03 is required.**  For use with earlier versions of OpenSCAD, download "fibonacci_sphere.2014.03.scad"  
   
7/28/14: Vertices are now lumped together into tetrahedra prior to hull operation. Previously, each vertex would be expressed by an individual tetrahedron of infinitesimal size as a way to work around OpenSCAD's lack of a "point()" module. This meant that for each vertex in the sphere, the hull operation would have to consider 4 times as many points. Major performance gains result from this change - runtime for a 100 vertex sphere has reduced from 25 seconds down to 3. This may be low enough to reap performance gains from `minkowski()` for certain low resolution fibonacci spheres. Additionally, the method signature for fibonacci_sphere has changed to include the standard `$fn` parameter. A fibonacci sphere should have roughly the same number of vertices as a sphere with the same value for `$fn`.  
   
7/25/14: Vertex positions are now calculated manually to reap performance gains. Previously, vertex positions were simulated via rotate/translate operations. On a 100 vertex sphere this shaves off about 10 seconds worth of rendering. Also, corrected an oversight causing rendered spheres to be 1mm larger in radius.