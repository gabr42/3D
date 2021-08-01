// bahtinov mask
// https://en.wikipedia.org/wiki/Bahtinov_mask

/*[ Telescope Geometry ]*/

// (mm) focal length of telescope or camera
focalLength = 70;

// (mm) inner diameter of the hole the cap sits inside
aperture = 70;

/*[ Cap Geometry ]*/

// (mm) how deep the cap sits inside the hole
capDepth = 0.1;

// (mm) how far beyond the aperture the cap extends
capEdge = 0.1;

// (mm) how thick the cap is
capThickness = 3;

// (mm) how thick the wall is that sits inside the hole
capWall = 0.1;

/*[ Mask Geometry ]*/

// Bahtinov factor
bFactor = 150; // [150:200]

// (mm) slats will not be smaller than this
minimumSlat = 2;

// (deg) angle between slats in different regions
slatAngle = 30; // [0:90]

// (mm) size of the center shadow structural disc
shadowSize = 0;

//
// END OF CONFIGURATION
//

// calculate the minimum slat stride
function slatStride(i) = (i * focalLength / bFactor > 2 * minimumSlat) ? (i * focalLength / bFactor) : slatStride(i + 2);

module slats(angle, d, offs) {
    stride = slatStride(1);
    endi = ceil(d / stride / 2);
    rotate([0, 0, angle]) intersection() {
        union() for (i = [-endi : endi]) translate([0, i * stride + offs]) {
            square([d, stride / 2], true);
        }
        circle(d=d);
    }
}

module mainSlats(d) {
    dividerSize = slatStride(1) / 2;
    intersection() {
        slats(0, d, 0);
        translate([-(d + dividerSize) / 2, -d / 2]) square([d / 2, d]);
    }
}

module upperSlats(d) {
    dividerSize = slatStride(1) / 2;
    intersection() {
        slats(slatAngle, d, dividerSize * cos(2 * slatAngle) / 2);
        translate([dividerSize / 2, dividerSize / 2]) square(d / 2, d / 2);
    }
}

module allSlats(d) {
    difference() {
        union() {
            mainSlats(d);
            upperSlats(d);
            mirror([0, 1]) upperSlats(d);
        }
        circle(d=shadowSize);
    }
}

module baseCap() {
    // the bottom layer
    cylinder(h=capThickness, d=aperture + 2 * capEdge);

    // the inside wall
    translate([0, 0, capThickness]) {
        // outer cylider - inner cylinder
        difference() {
            // outer cylinder has a chamfer
            union() {
                cylinder(h=capDepth - capWall / 2, d=aperture);
                translate([0, 0, capDepth - capWall / 2]) {
                    cylinder(h=capWall / 2, d1=aperture, d2=aperture - capWall);
                }
            }
            // inner cylinder
            cylinder(h=2 * capDepth, d=aperture - 2 * capWall);
        }
    }
}

module capWithSlats() {
    difference() {
        baseCap();
        translate([0, 0, -capThickness / 2]) linear_extrude(2 * capThickness) {
            allSlats(aperture - 2 * capWall);
        }
    }
}

$fn=128;
capWithSlats();
