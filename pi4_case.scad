//use <../finger_joint_box/finger_joint_box.scad>
//use </Users/aaronciuffo/Documents/Hobby/OpenSCAD/finger_joint_box/finger_joint_box.scad>
use <finger_joint_box.scad>
use <raspberrypi.scad>
use <packing_circles.scad>
use <voronoi.scad>


material = 2.3;
over = 6;
finger = 5;
piSize = [85, 56, 28];
// add the overage and material thickness to the measured pi sizes
caseSize = [ for (a = piSize) a + over + material*2 ];

//board footprint
brd_d = [85, 56, 1.6];
//locations
mountHole1_l = [brd_d[0]/2-3.5, brd_d[1]/2-3.5];
mountHole2_l = [brd_d[0]/2-3.5-58, brd_d[1]/2-3.5];

// Mounting Holes
mountingHole = 2.9;

// SD Card 
sdCard_d = [15.7, 12.2, 1.6];

//USB and Network Ports
ports_d = [50, 55, 19];
portsPwr_d = [53, 11.5, 7];

//hifi berry dimensions
//RCA Jacks
hifiRCA_d = [26, 9.5, 9];

//header dimensions
header_d = [52, 7.5, 8.5];


///voronoi values 
vor_round=1;
vor_border=10;
vor_thick=1;

module base() {
    union() {
        difference() {
            $fn = 36;
            faceB(caseSize, finger, finger, material, 0);
            // add mounting holes
            mounting_holes();
            my_random_voronoi(caseSize[0]-vor_border, caseSize[1]-vor_border, n=100, round=vor_round, thickness=vor_thick, center=true);
            //pack_circles(brd_d[0]-10, brd_d[1]-10, density=.6, min_radius=2, max_radius=5, min_separation=1.5, center=true);
            /*
            for (j = [-1, 1]) {
                translate([-1*mountHole1_l[0], j*mountHole1_l[1]])
                    circle(r=mountingHole/2);
                translate([-1*mountHole2_l[0], j*mountHole2_l[1]])
                    circle(r=mountingHole/2);
            }
            */
       }
       difference() {
           mounting_holes(d=mountingHole*3);
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

module left() {
    zMult = 1.2; // z height multiplyer for the sd card size
    difference() {
        echo("SD Card Slot height: ", sdCard_d[2]*zMult);
        faceC(caseSize, finger, finger, material);
        my_random_voronoi(caseSize[1]-vor_border, caseSize[2]-vor_border, n=30, round=vor_round, thickness=vor_thick, center=true);
        //pack_circles(brd_d[1]-10, caseSize[2]-10, density=.6, min_radius=2, max_radius=5, min_separation=1.5, center=true);
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
            // cut hole for usb, network port access
            translate([0, -caseSize[2]/2+ports_d[2]/2+material/2, 0])
                square([usableDiv(maxDiv(caseSize, finger))[1]*finger, ports_d[2]+material], center=true);
    //        translate([0, -(caseSize[2]-ports_d[2]-material-sdCard_d[2])/2, 0])
    //            #square([finger, ports_d[2]+material+sdCard_d[2]], center=true);
              
        }
        translate([0, -caseSize[2]/2+material+5/2/2+ports_d[2], 0])
            square([caseSize[1]-material*2, 5/2], center=true);
        
        translate([ports_d[0]/2+5/2, 0, 0])
            square([5/2, caseSize[2]-material*2], center=true);
        translate([-(ports_d[0]/2+5/2), 0, 0])
            square([5/2, caseSize[2]-material*2], center=true);
        /*
        difference() {
            translate([0, -caseSize[2]/2+ports_d[2]/2+material/2, 0])
                square([usableDiv(maxDiv(caseSize, finger))[1]*finger+5, ports_d[2]+5], center=true);       
           translate([0, -caseSize[2]/2+ports_d[2]/2+material/2-2.5, 0])
                square([usableDiv(maxDiv(caseSize, finger))[1]*finger, ports_d[2]+2.5], center=true);     
        }
        */
    }
}

//!right();


module front() {
    RCA_z = 23.5;
    union() {
        difference() {
            faceA(caseSize, finger, finger, material, 0);
            my_random_voronoi(caseSize[0]-vor_border, caseSize[2]-vor_border, n=50, round=vor_round, thickness=vor_thick, center=true);
            translate([0, -caseSize[2]/2+material+RCA_z, 0])
#                square([hifiRCA_d[0], hifiRCA_d[2]], center=true);
            translate([-brd_d[0]/2+portsPwr_d[0]/2+mountingHole*2, -caseSize[2]/2+portsPwr_d[2]/2+material+sdCard_d[2]+brd_d[2], 0])
                square([portsPwr_d[0], portsPwr_d[2]], center=true);
        }
        
        //RCA jacks
        
        difference() {
            translate([0, -caseSize[2]/2+material+RCA_z, 0])
               square([hifiRCA_d[0]+5, hifiRCA_d[2]+5], center=true);
            translate([0, -caseSize[2]/2+material+RCA_z, 0])
                square([hifiRCA_d[0], hifiRCA_d[2]], center=true);
            
        } 
        //power, hdmi ports
        difference() {
            translate([-brd_d[0]/2+portsPwr_d[0]/2+mountingHole*2, -caseSize[2]/2+portsPwr_d[2]/2+material+sdCard_d[2]+brd_d[2], 0])
                square([portsPwr_d[0]+5, portsPwr_d[2]+5], center=true);
            translate([-brd_d[0]/2+portsPwr_d[0]/2+mountingHole*2, -caseSize[2]/2+portsPwr_d[2]/2+material+sdCard_d[2]+brd_d[2], 0])
                square([portsPwr_d[0], portsPwr_d[2]], center=true);
        }
    }
}

//!front();

module back() {
    difference() {
        faceA(caseSize, finger, finger, material, 0);
        //pack_circles(brd_d[0]-10, caseSize[2]-10, density=.6, min_radius=2, max_radius=5, min_separation=1.5, center=true);
        my_random_voronoi(caseSize[0]-vor_border, caseSize[2]-vor_border, n=50, round=vor_round, thickness=vor_thick, center=true);
    }
}

module lid() {
    union() { 
        difference() { // difference the lid from the voronoi
            faceB(caseSize, finger, finger, material, 0);
            //pack_circles(brd_d[0]-10, brd_d[1]-10, density=.6, min_radius=2, max_radius=5, min_separation=1.5, center=true);
            my_random_voronoi(caseSize[0]-vor_border, caseSize[1]-vor_border, n=100, round=vor_round, thickness=vor_thick, center=true);
            mounting_holes(d=mountingHole);
            translate([-brd_d[0]/2+header_d[0]/2+7, brd_d[1]/2-header_d[1]*1.5, 0])
                square([header_d[0], header_d[1]], center=true);
        }
        // add back in the edge - mo fingers needed here
//       translate([0, -caseSize[1]/2+material/2, 0])
//            square([finger*9, material+.01], center=true);
        
        // add the mounting holes with a border
        difference() {
                // add a larger border around the mounting hole
                mounting_holes(d=mountingHole*3);
                // cut out the mounting hole
                mounting_holes(d=mountingHole);
        }
        
        // add a border around the header hole
        difference(){
            translate([-brd_d[0]/2+header_d[0]/2+7, brd_d[1]/2-header_d[1]*1.5, 0])
                square([header_d[0]+5, header_d[1]+5], center=true);     
            translate([-brd_d[0]/2+header_d[0]/2+7, brd_d[1]/2-header_d[1]*1.5, 0])
                //make sure the mounting holes don't get filled back in by the border around the header hole
                square([header_d[0], header_d[1]], center=true); 
            mounting_holes(d=mountingHole);
        }
    }
}

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
        children(0);
      
      color("blue") translate([-(caseSize[0]/2+caseSize[2]/2+material), 0, 0])
        rotate([0, 0, 90])
        children(1);
      
      color("darkblue") translate([(caseSize[0]/2+caseSize[2]/2+material), 0, 0])
        rotate([0, 0, -90])
        children(2);
      
     color("red") translate([0, -(caseSize[1]/2+caseSize[2]/2+material), 0])
        rotate([0, 0, 180])
        children(3);
      
     color("darkred") translate([0, caseSize[1]/2+caseSize[2]/2+material, 0])
        children(4);
      
     color("brown") translate([0, caseSize[1]+caseSize[2] + material*2, 0]) 
        children(5);
  }

}

layout(threeD=true) {
    base();
    left();
    right();
    front();
    back();
    lid();
}
