
 use <KeibelsVoronoiToolboxV2.1.scad>;
// Draws a Wall and substracts the voronoi chunks
$fn=36; $fa=20;
dimCUBE2=[1000,1000,1000];//  dx= x-edge,dy=y-edge dz=hight of cube

translate([-20,-20,0])
    Voronoi_StructureAKL(
        type="CUBE", 
        dim=dimCUBE2, 
        n=500, 
        thickness=10, 
        walls=0, 
        round = 0, 
        seed = 8, 
        showDots=false, 
        renderit=true);
        