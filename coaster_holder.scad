in=25.4;

// Thickness of material
t     = .2*in;

// Height (outside of box)
H     = 2*in;

// Width  (outside of box)
W     = 4.05*in+2*t; //4.25->3.85

// Length (outside of box)
L     = W;//4*in;

// Height of legs
Hleg  = .5*in;

// Length of legs (length that touches surface)
Lleg  = .5*in;

// Length of legs at top of leg (greater than Lleg)
LlegT = 1*in; 

//Number of tabs across the smaller of the front or side.
Ntabs = 5; 

DISPLAY=1; //[1:Flat Pattern (2D), 0:Assembly (3D)]

// interfearance (bigger number makes tighter fit)
interfearance = 0.1;

//Explode Factor (multiple of thickness
explode_factor =0;


if (DISPLAY)
{
    render()
    box_flat_pattern();
}
else
{
    box_assembly();
}

/////////////////////
// END USER INPUTS //
/////////////////////


$fn=100;
echo("inside dimensions:",(W-2*t),(L-2*t),(H-2*t-Hleg));

Lavail_front = W-2*max(LlegT,Lleg);
Lavail_side  = L-2*max(LlegT,Lleg);
Lavail_min = min(Lavail_front,Lavail_side);
Wtab = Lavail_min/(Ntabs*2-1);
Wpin = Wtab; // Width of the tab used as a pin in the hinge joint

// Define colors components 
gamma = 1; // transparency level (value between 0.0 and 1.0)
Color_front  = [1.0,0.5,0.5,gamma];
Color_back   = [0.5,1.0,0.5,gamma];
Color_side_1 = [0.5,0.5,1.0,gamma];
Color_side_2 = [1.0,1.0,0.5,gamma];
Color_bottom = [0.5,1.0,1.0,gamma];
Color_top    = [1.0,0.5,1.0,gamma];

// Calculate the Effective diameter of the pin tab  
Dpin     = sqrt(Wtab*Wpin + t*t);

// Calculate the position of the pin tab hole
Xhole    = L/2-Dpin/2-t;

// dH is how much needs to be cut off from the back to
// provide clearance for the lid to open
Rswing = sqrt( (L/2-Xhole)*(L/2-Xhole) + (t/2)*(t/2) );
xswing = L/2-Xhole-t;
yswing = Rswing*sin(acos(xswing/Rswing));
swing_fudge  = .5; //Additional clearance just to be sure
dH = yswing-t/2+swing_fudge;

Lavail_edge = H-2*t; //H-2*(dH+t);

// Calculate the Radius and center location for
// the cut that make the arc in the legs
x1   = Wtab*(Ntabs*2-1)/2;   //Wtab*2.5;
y1   = Hleg;
x2   = ( min(W,L)-Lleg*2 )/2;
yc   = -(y1*y1 + x1*x1 - x2*x2) / (2*y1);
Rleg =  sqrt(x2*x2+yc*yc);

/////////////////////////////
//Start Module Definitions //
/////////////////////////////

module box_flat_pattern()
{
    fsep=1.05;
    Hsep1 = (H)*fsep;
    Hsep2 = L*fsep;
    Hsep3 = W*fsep;
    Hsep4 = (W/2)*fsep;
    color(Color_front) translate([ Hsep3*0 , 0       ]) front();
    color(Color_back)  translate([ Hsep3*1 , 0       ]) back();
    color(Color_side_1)translate([ 0       , Hsep1*1 ]) side(flip=false);
    color(Color_side_2)translate([ Hsep2*1 , Hsep1*1 ]) side(flip=true);
    color(Color_bottom)translate([ L/2     ,-Hsep4*1 ]) rotate(90) bottom();
}

module box_assembly()
{
    e = explode_factor*t;
    
    color(Color_front)
    translate([0,-L/2+t-e,0])rotate([90,0,0])linear_extrude(t)front();

    color(Color_back)
    translate([0, L/2-0+e,0])rotate([90,0,0])linear_extrude(t)back();

    color(Color_side_1)
    translate([W/2-t+e, 0,0])
        rotate([0,90,0])
            linear_extrude(t)
                rotate(90) side(flip=false);
    color(Color_side_2)
    translate([-W/2+t-e, 0,0])
        rotate([0,90,180])
            linear_extrude(t)
                rotate(90)side(flip=true);
    
    color(Color_bottom)
    translate([0, -L/2,Hleg])
        linear_extrude(t)
            bottom();
}

module front()
{
    difference()
    {
        translate([-W/2,0]) square([W,H]);
        difference()
        {
            union()
            {
                delta = (W-min(W,L))/2;
                translate([ delta,-yc]) circle(r=Rleg);
                translate([-delta,-yc]) circle(r=Rleg);
                square([2*delta,Hleg*2],center=true);
            }
            translate([-L/2,Hleg]) square([L,H]);
        }
        translate([ W/2,H/2]) tabs(Length_in=Lavail_edge);
        translate([-W/2,H/2]) tabs(Length_in=Lavail_edge);
        rotate(90)
        {
            translate([Hleg,0]) slots(Length_in=Lavail_front);
        }
        translate([0,(H+Hleg)/2+t/2])
            pattern(Xs=L-4*t,Ys=(H-Hleg)-3*t);
    }
}

module back()
{
    front();
}

module side(flip=false)
{
    difference()
    {
        translate([-L/2,0]) square([L,H]);
        difference()
        {
            union()
            {
                delta = (L-min(W,L))/2;
                translate([ delta,-yc]) circle(r=Rleg);
                translate([-delta,-yc]) circle(r=Rleg);
                square([2*delta,Hleg*2],center=true);
            }
            translate([-L/2,Hleg]) square([L,H]);
        }
        translate([-L/2,H/2]) slots(Length_in=Lavail_edge);
        translate([ L/2,H/2]) slots(Length_in=Lavail_edge);
        rotate(90)
        {
            translate([Hleg,0]) slots(Length_in=Lavail_side);
        }
        translate([0,(H+Hleg)/2+t/2])
            pattern(Xs=L-4*t,Ys=(H-Hleg)-3*t);
    }
}

module bottom()
{
    difference()
    {
        translate([-W/2,0]) square([W,L]);
        translate([ W/2,L/2]) tabs(Length_in=Lavail_side);
        translate([-W/2,L/2]) tabs(Length_in=Lavail_side);
        rotate(90)
        {
            translate([ 0,0]) tabs(Length_in=Lavail_front);
            translate([ L,0]) tabs(Length_in=Lavail_front);
        }
        translate([0,L/2])
            pattern(Xs=W-4*t,Ys=L-4*t,Nn=65);
    }
}

module tabs(Length_in=0)
{
    Nt = floor(max((Length_in/Wtab+1)/2,1));  
    start = -(Nt-1)/2;  
    difference()
    {
        square([2*t,max(H,W,L)*1.1],center=true);          
        for (i=[0:Nt-1])
        {
            pos = (start+i)*Wtab*2;
            translate([0,pos]) square([4*t,Wtab+interfearance*2],center=true);
        }
    }
}

module slots(Length_in=0)
{
    Nt = floor(max((Length_in/Wtab+1)/2,1)); 
    start = -(Nt-1)/2;
    for (i=[0:Nt-1])
    {
        pos = (start+i)*Wtab*2;
        translate([0,pos]) square([2*t,Wtab],center=true);
    }
}

module top_tabs()
{
    difference()
    {
        square([2*t,max(H,W,L)*2],center=true);        
        translate([0,i*Wtab*2])
            square([4*t,Wtab],center=true);
    }
}

module pattern(Xs,Ys,Nn=30)
{
    
    my_random_voronoi( n = Nn,
                        thickness=1,
                        round=1,
                        xsize = Xs,
                        ysize = Ys,
                        center=true);
    
}

///////////////////////////////////////////////////////////////////////////////
// The Voronoi code below this line is derived from the voronoi code available
// on Thingiverse at http://www.thingiverse.com/thing:47649
//
// (c)2013 Felipe Sanches <juca@members.fsf.org>
// licensed under the terms of the GNU GPL version 3 (or later)

function normalize(v) = v / (sqrt(v[0] * v[0] + v[1] * v[1]));

module voronoi(points, L = 200, thickness = 1, round = 6, nuclei = true) {
	for (p = points) {
		difference() {
			minkowski() {
				intersection_for(p1 = points){
					if (p != p1) {
						angle = 90 + atan2(p[1] - p1[1], p[0] - p1[0]);

						translate((p + p1) / 2 - normalize(p1 - p) * (thickness + round))
						rotate([0, 0, angle])
						translate([-L, -L])
						square([2 * L, L]);
					}
				}
				circle(r = round, $fn = 20);
			}
			if (nuclei)
				translate(p) circle(r = 1, $fn = 20);
		}
	}
}

module my_random_voronoi(   n = 20,
                            thickness = 1,
                            round = 6,
                            xsize = 50,
                            ysize = 100,
                            seed = undef,
                            center = false)
{
    xmin=0;
    ymin=0;
    L = max(xsize,ysize);
    seed = seed == undef ? rands(0, 100, 1)[0] : seed;
	echo("Seed", seed);

	// Generate points.
	x = rands(xmin, xsize, n, seed);
	y = rands(ymin, ysize, n, seed + 1);    
	points = [ for (i = [0 : n - 1]) [x[i], y[i]] ];
        
	// Center Voronoi.
	offset_x = center ? -(max(x) - min(x)) / 2 : 0;
	offset_y = center ? -(max(y) - min(y)) / 2 : 0;
    
    intersection()
    {
        square([xsize,ysize],center=center);
        translate([offset_x, offset_y])    
            voronoi(points, L = L, thickness = thickness, round = round, nuclei = false);
    }
}


// example with an explicit list of points:
/*
point_set = [
	[0, 0], [30, 0], [20, 10], [50, 20], [15, 30], [85, 30], [35, 30], [12, 60],
	[45, 50], [80, 80], [20, -40], [-20, 20], [-15, 10], [-15, 50]
];
voronoi(points = point_set, round = 4, nuclei = true);
*/

// example with randomly generated set of points
//my_random_voronoi(n = 30, thickness=2,round=6,xsize = 100, ysize = 300, seed = undef,nuclei = false );

// End of voronoi code
///////////////////////////////////////////////////////////////////////////////