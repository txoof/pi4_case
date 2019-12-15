//use <../finger_joint_box/finger_joint_box.scad>
//use </Users/aaronciuffo/Documents/Hobby/OpenSCAD/finger_joint_box/finger_joint_box.scad>
use <finger_joint_box.scad>
use <raspberrypi.scad>
use <packing_circles.scad>
use <voronoi.scad>


material = 3.4;
over = 6;
finger = 5;
piSize = [85, 56, 28];
// add the overage and material thickness to the measured pi sizes
caseSize = [ for (a = piSize) a + over + material*2 ];

// feet for the case
foot_x = (caseSize[0]-usableDiv(maxDiv(caseSize, finger))[0]*finger)/2;
foot_ratio = .5;
foot_h = 8;

//board footprint
brd_d = [85, 56, 1.6];
//locations
mountHole1_l = [brd_d[0]/2-3.5, brd_d[1]/2-3.5];
mountHole2_l = [brd_d[0]/2-3.5-58, brd_d[1]/2-3.5];

// Mounting Holes
mountingHole = 2.9;

// SD Card 
sdCard_d = [15.7, 12.2, 1.4];

//USB and Network Ports
ports_d = [52.5, 55, 19.2];
portsPwr_d = [53, 11.5, 8];

//hifi berry dimensions
//RCA Jacks
hifiRCA_d = [27, 9.5, 11];

//header dimensions
header_d = [52, 7.5, 8.5];


///voronoi values 
vor_round=1;
vor_border=(5+material)*2;
vor_thick=1;

//cutout border to use around all cutout holes 
cutout_border = 5;


module foot(w, h, ratio, center=false) {
    q = w - w*(1-ratio);

    trans_coord = center ? [-w/2, -h/2] : [0, 0, 0];
    
    coords = [[0, 0], [w, 0], 
              [q, h], [0, h]];
    translate(trans_coord) 
        polygon(coords);
    
}



module feet() {
    translate([-(caseSize[0]/2-foot_x/2), -(caseSize[2]/2+foot_h/2), 0]) 
        rotate([180, 0, 0])
        foot(foot_x, foot_h, foot_ratio, true);
    translate([(caseSize[0]/2-foot_x/2), -(caseSize[2]/2+foot_h/2), 0]) 
        rotate([180, 180, 0])
        foot(foot_x, foot_h, foot_ratio, true);
}




module base() {
    vor_d = [caseSize[0]-vor_border, caseSize[1]-vor_border];
    union() {
        difference() {
            $fn = 36;
            faceB(caseSize, finger, finger, material, 0);
            // add mounting holes
            mounting_holes(mountingHole);
            my_random_voronoi(vor_d[0], vor_d[1], n=100, round=vor_round, thickness=vor_thick, center=true);
            translate([caseSize[0]/2-material, (caseSize[1]/4), 0])
                rotate([0, 180 , 90])
                    text("Aaron Ciuffo https://github.com/txoof/pi4_case", size=material*.5, font="Anton");
       }
       difference() {
           mounting_holes(d=mountingHole+cutout_border);
           mounting_holes(d=mountingHole);
           
       }
       //no fingers needed here for sd card slot
       translate([-caseSize[0]/2+material/2, 0])
        square([material+.01, finger*3], center=true); //add a little to the X value
       
       //no fingers needed under the usb/network ports
       translate([caseSize[0]/2-material/2, 0, 0])
        square([material, usableDiv(maxDiv(caseSize, finger))[1]*finger], center=true);
   }
   
}
//!base();


module left() {
    zMult = 1.2; // z height multiplyer for the sd card size
    difference() {
        echo("SD Card Slot height: ", sdCard_d[2]*zMult);
        faceC(caseSize, finger, finger, material);
        my_random_voronoi(caseSize[1]-vor_border, caseSize[2]-vor_border, n=30, round=vor_round, thickness=vor_thick, center=true);
        // remove a slot for sd card access
        translate([0, -caseSize[2]/2 + (sdCard_d[2]*zMult + material)/2 , 0])
            square([sdCard_d[0], sdCard_d[2]*zMult + material], center=true);
    }
}
//!left();

module right() {
    union() {
        difference() {
            faceC(caseSize, finger, finger, material);
             my_random_voronoi(caseSize[1]-vor_border, caseSize[2]-vor_border, n=30, round=vor_round, thickness=vor_thick, center=true);
 
            // cut out space for usb, network port
            //translate([0, -(caseSize[2]-ports_d[2]-material-sdCard_d[2])/2, 0])
            translate([0, -(caseSize[2]/2-ports_d[2]/2-material), 0])
                square([ports_d[0], ports_d[2]], center=true);
            //cut off the fingers - not needed here
            translate([0, -(caseSize[2]/2-material/2), 0])
                square([caseSize[1], material], center=true);
        }
        //add a bordered region around the port 
        difference() {
            translate([0, -(caseSize[2]/2-ports_d[2]/2-material), 0])
                square([ports_d[0]+cutout_border, ports_d[2]+cutout_border], center=true);
            translate([0, -(caseSize[2]/2-ports_d[2]/2-material), 0])
                square([ports_d[0], ports_d[2]], center=true);
            translate([0, -(caseSize[2]/2), 0])
                square([caseSize[1], material*2], center=true);
        }
    }
}

//!right();


module front() {
    RCA_z = 23.5;
    power_z = -(caseSize[2]/2-material*2-sdCard_d[2]-brd_d[2]);
    power_x = -brd_d[0]/2+portsPwr_d[0]/2+mountingHole*2;
    union() {
        difference() {
            faceA(caseSize, finger, finger, material, 0);
            my_random_voronoi(caseSize[0]-vor_border, caseSize[2]-vor_border, n=50, round=vor_round, thickness=vor_thick, center=true);
            translate([0, -caseSize[2]/2+material+RCA_z, 0])
                square([hifiRCA_d[0], hifiRCA_d[2]], center=true);
//            translate([-brd_d[0]/2+portsPwr_d[0]/2+mountingHole*2, -caseSize[2]/2+portsPwr_d[2]/2+material+sdCard_d[2]+brd_d[2], 0])
              translate([power_x, power_z, 0])
                square([portsPwr_d[0], portsPwr_d[2]], center=true);
        }
        
        //RCA jacks
        
        difference() {
            translate([0, -caseSize[2]/2+material+RCA_z, 0])
               square([hifiRCA_d[0]+cutout_border, hifiRCA_d[2]+cutout_border], center=true);
            translate([0, -caseSize[2]/2+material+RCA_z, 0])
                square([hifiRCA_d[0], hifiRCA_d[2]], center=true);
            
        } 
        //power, hdmi ports
        difference() {
            translate([power_x, power_z, 0])
                square([portsPwr_d[0]+cutout_border, portsPwr_d[2]+cutout_border], center=true);
            translate([power_x, power_z, 0])
                square([portsPwr_d[0], portsPwr_d[2]], center=true);
        }
        feet();
    }
}

//!front();



module back() {
    foot_x = (caseSize[0]-usableDiv(maxDiv(caseSize, finger))[0]*finger)/2;
    foot_ratio = .5;
    foot_h = 10;
    
    
    
    union() {
        difference() {
            faceA(caseSize, finger, finger, material, 0);
            my_random_voronoi(caseSize[0]-vor_border, caseSize[2]-vor_border, n=50, round=vor_round, thickness=vor_thick, center=true);
        }
        
        //add some feet
        feet();

    
        
    }
}

//!back();

module lid() {
    header_x = -brd_d[0]/2+header_d[0]/2+6.5;
    header_y = brd_d[1]/2-header_d[1]*1.1;
    
    union() { 
        difference() { // difference the lid from the voronoi
            faceB(caseSize, finger, finger, material, 0);
            my_random_voronoi(caseSize[0]-vor_border, caseSize[1]-vor_border, n=100, round=vor_round, thickness=vor_thick, center=true);
            mounting_holes(d=mountingHole);
            //header holes
            translate([header_x, header_y, 0])
                square([header_d[0], header_d[1]], center=true);
        }
 
        // add the mounting holes with a border
        difference() {
                // add a larger border around the mounting hole
                mounting_holes(d=mountingHole+cutout_border);
                // cut out the mounting hole
                mounting_holes(d=mountingHole);
        }
        
        // add a border around the header hole
        difference(){
            translate([header_x, header_y, 0])
                square([header_d[0]+cutout_border, header_d[1]+cutout_border], center=true);     
            translate([header_x, header_y, 0])
                square([header_d[0], header_d[1]], center=true); 
            //make sure the mounting holes don't get filled back in by the border around the header hole
            mounting_holes(d=mountingHole);
        }
    }
}

//!lid();

module mounting_holes(d=2.9) {
    $fn=36;
    for (j = [-1, 1]) {
        translate([-1*mountHole1_l[0], j*mountHole1_l[1]])
            circle(r=d/2);
        translate([-1*mountHole2_l[0], j*mountHole2_l[1]])
            circle(r=d/2);
    }
}

module layout(threeD=true) {
  if (threeD) {
    color("green") translate([0, 0, 0])
        linear_extrude(height=material, center=true)
        children(0);
    
    color("blue") 
      translate([-caseSize[0]/2+material/2, 0, caseSize[2]/2-material/2]) 
      rotate([90, 0, -90])
        linear_extrude(height=material, center=true)
        children(1);
     
    color("darkblue")
      translate([caseSize[0]/2-material/2, 0, caseSize[2]/2-material/2])
      rotate([90, 0, -90])
        linear_extrude(height=material, center=true)
        children(2);


    color("red") 
      translate([0, -caseSize[1]/2+material/2, caseSize[2]/2-material/2])
      rotate([90, 0, 0])
        linear_extrude(height=material, center=true)
        children(3);
        
    color("darkred")
        translate([0, caseSize[1]/2-material/2, caseSize[2]/2-material/2])
            rotate([90, 0, 0])
                linear_extrude(height=material, center=true)
                children(4);
    
    color("brown")
        translate([0, 0, caseSize[2]-material])
            rotate([0, 0, 0])
                linear_extrude(height=material, center=true)
                children(5);
    
      translate([0, 0, material/2+sdCard_d[2]]) {
        pi3();    
        hifiberryDacPlus(withHeader=true);
 
    }
  
  } else {
      color("green") translate([0, 0, 0])
        rotate([0, 180, 0])
        children(0);
      
      color("blue") translate([-(caseSize[0]/2+caseSize[2]/2+material), -(caseSize[1]+material), 0])
        rotate([0, 0, 90])
        children(1);
      
      color("darkblue") translate([-(caseSize[0]/2+caseSize[2]/2+material), 0, 0])
        rotate([0, 0, 90])
        children(2);
      
     color("red") translate([0, -(caseSize[1]/2+caseSize[2]/2+material), 0])
        rotate([0, 0, 0])
        children(3);
      
     color("darkred") translate([0, caseSize[1]*1.5+caseSize[2]/2+material+foot_h, 0])
        children(4);
      
     color("brown") translate([0, caseSize[1] + material, 0]) 
        children(5);
  }

}

layout(threeD=false) {
    base();
    left();
    right();
    front();
    back();
    lid();
}
