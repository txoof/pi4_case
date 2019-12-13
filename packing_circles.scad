sizeX = 150;
sizeY = 150;
min_radius = 5;
max_radius = 50;
total_circles = 20;

function __is_float(value) = value + 0 != undef;

function rand(min_value = 0, max_value = 1, seed_value) = 
    __is_float(seed_value) ? rands(min_value, max_value , 1, seed_value)[0] : rands(min_value, max_value , 1)[0];

function _packing_circles_out_of_range(size, c) =
    c[0] + c[2] >= size[0] || 
    c[0] - c[2] <= 0 ||
    c[1] + c[2] >= size[1] || 
    c[1] - c[2] <= 0;
    
function _packing_circles_overlapping(circles, c, i = 0) = 
    i == len(circles) ? false : 
        let(
            x = c[0] - circles[i][0],
            y = c[1] - circles[i][1],
            a = c[2] + circles[i][2],
            collision = a >= sqrt(x * x + y * y)
        )
        collision || _packing_circles_overlapping(circles, c, i + 1);
    
function _packing_circles_packable(size, circles, c) =
    !_packing_circles_overlapping(circles, c) && 
    !_packing_circles_out_of_range(size, c);

function _packing_circles_new_min_circle(size, min_radius, attempts, circles, i = 0) = 
    i == attempts ? [] :
        let(c = [rand() * size[0], rand() * size[1], min_radius])
        _packing_circles_packable(size, circles, c) ? c : 
        _packing_circles_new_min_circle(size, min_radius, attempts, circles, i + 1);

function _packing_circles_increase_radius(size, circles, c, max_radius) = 
    c[2] == max_radius || !_packing_circles_packable(size, circles, c) ? 
        [c[0], c[1], c[2] - 1] : 
        _packing_circles_increase_radius(size, circles, [c[0], c[1], c[2] + 1], max_radius);


function _packing_circles_new_circle(size, min_radius, max_radius, attempts, circles) = 
    let(c = _packing_circles_new_min_circle(size, min_radius, attempts, circles))
    c == [] ? [] : _packing_circles_increase_radius(size, circles, c, max_radius);

function _packing_circles(size, min_radius, max_radius, total_circles, attempts, circles = [], i = 0) =
    i == total_circles ? circles :
    let(c = _packing_circles_new_circle(size, min_radius, max_radius, attempts, circles))
    c == [] ? _packing_circles(size, min_radius, max_radius, total_circles, attempts, circles) :
    _packing_circles(size, min_radius, max_radius, total_circles, attempts, concat(circles, [c]), i + 1);

function packing_circles(size, min_radius, max_radius, total_circles, attempts = 100) = 
    _packing_circles(__is_float(size) ? [size, size] : size, min_radius, max_radius, total_circles, attempts);

/*    
circles = packing_circles([sizeX, sizeY], min_radius, max_radius, total_circles);
mr = max([for(c = circles) c[2]]);
translate([0, 0, mr]) for(c = circles) {
    translate([c[0], c[1]])
        sphere(c[2], $fn = 48);
}
for(c = circles) {
    translate([c[0], c[1]])
        linear_extrude(mr) 
           circle(c[2]/ 3, $fn = 48);
}
linear_extrude(1) square([sizeX, sizeY]);
*/

function maximum(a, i = 0) = (i < len(a) - 1) ? max(a[i], maximum(a, i +1)) : a[i];

function minimum(a, i = 0) = (i < len(a) - 1) ? min(a[i], minimum(a, i +1)) : a[i];


module pack_circles(sizeX=200, sizeY=200, min_radius=5, max_radius=8, density=0.4) {
    
    avg_circle = PI*pow(((min_radius+max_radius)/2), 2);
    
    total_circles = ceil(((sizeX*sizeY)/avg_circle)*density );
    echo(total_circles);

    //max_radius = minimum([sizeX, sizeY])*.8;
    circles = packing_circles([sizeX, sizeY], min_radius, max_radius, total_circles);
    mr = max([for(c = circles) c[2]]); 
    for(c = circles) {
        translate([c[0], c[1]])
            //sphere(c[2], $fn = 48);
            circle(c[2], $fn=36);
    }
}


//!echo((200*200)/(PI*pow((8+5)/2, 2)));
pack_circles(min_radius=3, max_radius=8, density=0.2);
