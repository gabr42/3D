use <solids.pipe.scad>

//d 35 x 40
//d 32 x 20 - 60 st.C

d1 = 35; h1 = 40;
d2 = 32; h2 = 20;
h2d = 10; r2c = 10;
wall = 3;

$fn = $preview ? 50 : 100;

pipe(d = d1, h = h1, wall = wall)
adapter(d1 = d2, d2 = d1, h = h2d, wall = wall)  
knee(d = d2, r_out = r2c, wall = wall, angle = 90)
pipe(d = d2, h = h2, wall = wall);
