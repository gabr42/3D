/***********************************************************\
 * Voroni  Toolbox by Andreas Keibel                       *
 *                                                         * 
 * (c)2019 Dr.-Ing. Andreas Keibel <a.keibel@systragon.de> *
 *                                                         * 
 * For licensing contact me by email, please               *
 *                                                         * 
 * for 15€ per Paypal I send you a well commented version  *
 * :-)                                                     * 
\***********************************************************/
 use <KeibelsVoronoiToolbox.scad>;

$fn=120;

// Draws a Torus-Ring and substracts the voronoi chunks
dimTORUS=[55,12,40];//  dx= middle radius of torus,dy=x-radius ellipse, dz=hight of ellipse

     Voronoi_StructureAKL(
        type="TORUS",         // Select the type TORUS,SPHERE,CUBE,CYLINDER 
        dim=dimTORUS,       // Size-Parameters of the resulting object
        n=20,              // Number of random voronoi cores. Beware Runtime goes with n²! 
        thickness=5,       // thickness of the links  
        walls=5,           // thickness of the outside walls on hollow objects
                           // walls=0 draws a massive structure with hole inside
                           // (not for Torus)
        round = 3,         // Roundings of the inside angles of the Voronoi-Polygons 
        seed = 5,          // Adjusting the random-generator. 
        showDots=false);   // Show the cores, if you like for reference 
        

// Draws a CUBE and substracts the voronoi chunks
dimCUBE=[120,120,240];//  dx= x-edge,dy=y-edge dz=hight of cube

translate([200,0,0])
    Voronoi_StructureAKL(
        type="CUBE", 
        dim=dimCUBE, 
        n=20, 
        thickness=5, 
        walls=15, 
        round = 3, 
        seed = 5, 
        showDots=true);
        
// Draws a CYLINDER and substracts the voronoi chunks
dimCYLINDER=[55,55,240];//  dx= x-edge,dy=y-edge dz=hight of cube

translate([0,200,0])
    Voronoi_StructureAKL(
        type="CYLINDER", 
        dim=dimCYLINDER, 
        n=20, 
        thickness=5, 
        walls=20, 
        round = 3, 
        seed = 5, 
        showDots=true);


// Draws a CUBE and substracts the voronoi chunks
translate([200,200,0])
    Voronoi_StructureAKL(
        type="CUBE", 
        dim=dimCUBE, 
        n=20, 
        thickness=5, 
        walls=50, 
        round = 3, 
        seed = 5, 
        showDots=true);

// Draws a Wall and substracts the voronoi chunks
dimCUBE2=[440,10,240];//  dx= x-edge,dy=y-edge dz=hight of cube

translate([-150,-150,0])
    Voronoi_StructureAKL(
        type="CUBE", 
        dim=dimCUBE2, 
        n=50, 
        thickness=5, 
        walls=0, 
        round = 3, 
        seed = 7, 
        showDots=true);

// Draws a SPHERE and substracts the voronoi chunks
dimSPHERE=[60,60,60];//  dx= x-Diameter,dy=y-diameter dz=hight of cube

translate([-150,0,0])
    Voronoi_StructureAKL(
        type="SPHERE", 
        dim=dimSPHERE, 
        n=30, 
        thickness=3, 
        walls=2, 
        round = 3, 
        seed = 15, 
        showDots=true);
