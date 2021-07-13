"c:\Program Files\Prusa3D\PrusaSlicer\prusa-slicer-console.exe" -g -max-print-speed 20 -output twisty1-20.gcode twisty1.3mf
"c:\Program Files\Prusa3D\PrusaSlicer\prusa-slicer-console.exe" -g -max-print-speed 15 -output twisty1-15.gcode twisty1.3mf
"c:\Program Files\Prusa3D\PrusaSlicer\prusa-slicer-console.exe" -g -max-print-speed 10 -output twisty1-10.gcode twisty1.3mf
"c:\Program Files\Prusa3D\PrusaSlicer\prusa-slicer-console.exe" -g -max-print-speed 7.5 -output twisty1-7_5.gcode twisty1.3mf
"c:\Program Files\Prusa3D\PrusaSlicer\prusa-slicer-console.exe" -g -max-print-speed 5 -output twisty1-5.gcode twisty1.3mf

h:\RAZVOJ\3D\utilities\combiner\Win32\Debug\Combine.exe twisty1-a.gcode twisty1-20.gcode 30 twisty1-15.gcode 40 twisty1-10.gcode 45 twisty1-7_5.gcode 60 twisty1-5.gcode

del twisty1-20.gcode
del twisty1-15.gcode
del twisty1-10.gcode
del twisty1-7_5.gcode
del twisty1-5.gcode

h:\RAZVOJ\3D\utilities\mirror\Win32\Debug\Mirror.exe twisty1-b.gcode twisty1-a.gcode x125
