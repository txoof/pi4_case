//use <../finger_joint_box/finger_joint_box.scad>
//use </Users/aaronciuffo/Documents/Hobby/OpenSCAD/finger_joint_box/finger_joint_box.scad>
use <finger_joint_box.scad>
use <raspberrypi.scad>
use <packing_circles.scad>


material = 2.3;
over = 0.5;
finger = 3;
piSize = [85, 56, 27.2];
// add the overage materail thickness to the measured pi sizes
caseSize = [ for (a = piSize) a + over+2 + material*2 ];

//board footprint
brd_d = [85, 56, 1.6];

// SD Card 
sdCard_d = [15.7, 12.2, 1.6];
//sdCard_l = [-85/2-13+sdCard_d[0]/2, 24.5+3.5, 0];

// Mounting Holes
mountingHole = 2.9;
//locations
mountHole1_l = [brd_d[0]/2-3.5, brd_d[1]/2-3.5];
mountHole2_l = [brd_d[0]/2-3.5-58, brd_d[1]/2-3.5];

//USB and Network Ports
ports_d = [0, 53, 15.1];
portsPwr_d = [47.5+3, 11.5, 6];

//hifi berry dimensions
//RCA Jacks
hifiRCA_d = [29, 9.5,11];

//header dimensions
header_d = [51, 6, 8.5];


module slots(slotD, area) {
    
}


module vent_holes(sizeX=100, sizeY=100, min_radius=5, max_radius=15, total_circles=10) {
    circles = packing_circles([sizeX, sizeY], min_radius, max_radius, total_circles);
    mr = max([for(c = circles) c[2]]);
    translate([0, 0, mr]) for(c = circles) {
        translate([c[0], c[1]])
            sphere(c[2], $fn = 48);
    }
}

//!vent_holes();

module base() {
    union() {
        difference() {
            $fn = 36;
            faceB(caseSize, finger, finger, material, 0);
            // add mounting holes
            mounting_holes();
            /*
            for (j = [-1, 1]) {
                translate([-1*mountHole1_l[0], j*mountHole1_l[1]])
                    circle(r=mountingHole/2);
                translate([-1*mountHole2_l[0], j*mountHole2_l[1]])
                    circle(r=mountingHole/2);
            }
            */
       }
       //no fingers needed here for sd card slot
       translate([-caseSize[0]/2+material/2, 0])
        square([material, finger*3], center=true);
       
       translate([caseSize[0]/2-material/2, 0, 0])
        square([material, finger*17], center=true);
   }
}


module left() {
    difference() {
        zMult = 2; // z height multiplyer for the sd card size
        echo("SD Card Slot height: ", sdCard_d[2]*zMult);
        faceC(caseSize, finger, finger, material);
        // remove a slot for sd card access
        translate([0, -caseSize[2]/2 + (sdCard_d[2]*zMult + material)/2 , 0])
            square([finger*5, sdCard_d[2]*zMult + material], center=true);
    }
}

module right() {
    difference() {
        faceC(caseSize, finger, finger, material);
        // cut hole for usb, network port access
//        translate([0, -caseSize[2]/2+ports_d[2]/2+material/2, 0])
        translate([0, -(caseSize[2]-ports_d[2]-material-sdCard_d[2])/2, 0])
            square([finger*17, ports_d[2]+material+sdCard_d[2]], center=true);
    }
    
}


module front() {
    difference() {
        faceA(caseSize, finger, finger, material, 0);
        translate([0, caseSize[2]/2-hifiRCA_d[2]/2-material/2])
            square([finger*9, hifiRCA_d[2]+material], center=true);
        translate([-brd_d[0]/2+portsPwr_d[0]/2+6, -caseSize[2]/2+portsPwr_d[2]/2+material+sdCard_d[2]+brd_d[2], 0])
            square([portsPwr_d[0], portsPwr_d[2]], center=true);
    }
}

//front();

module back() {
    difference() {
        faceA(caseSize, finger, finger, material, 0);
    }
}

module lid() {
    union() {
        difference() {
            faceB(caseSize, finger, finger, material, 0);
            translate([-brd_d[0]/2+header_d[0]/2+7, brd_d[1]/2-header_d[1]*1.5, 0])
                square([header_d[0], header_d[1]], center=true);
            mounting_holes();
        }
        translate([0, -caseSize[1]/2+material/2, 0])
            square([finger*9, material], center=true);
    }
}


module mounting_holes() {
    $fn=36;
    for (j = [-1, 1]) {
        translate([-1*mountHole1_l[0], j*mountHole1_l[1]])
            circle(r=mountingHole/2);
        translate([-1*mountHole2_l[0], j*mountHole2_l[1]])
            circle(r=mountingHole/2);
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
    
    color("limegreen")
        translate([0, 0, caseSize[2]-material])
            rotate([0, 0, 0])
                linear_extrude(height=material, center=true)
                children(5);
    
      translate([0, 0, material/2+sdCard_d[2]]) {
        pi3();    
        hifiberryDacPlus(withHeader=true);
 
    }
  
  }

}

layout() {
    base();
    left();
    right();
    front();
    back();
    lid();
}
