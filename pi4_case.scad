//use <../finger_joint_box/finger_joint_box.scad>
//use </Users/aaronciuffo/Documents/Hobby/OpenSCAD/finger_joint_box/finger_joint_box.scad>
use <finger_joint_box.scad>
use <raspberrypi.scad>


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

//hifi berry dimensions
//RCA Jacks
hifiRCA_d = [29, 9.5,11];

//header dimensions
header_d = [51, 6, 8.5];

//color("red") {
//    faceA(caseSize, finger, finger, material, 0);
//}
//lid/bottom
//color("green") {
//    faceB(caseSize, finger, finger, material, 0);
//}
//color("blue") {
//    faceC(caseSize, finger, finger, material);
//}

module base() {
    union() {
        difference() {
            $fn = 36;
            faceB(caseSize, finger, finger, material, 0);
            // add mounting holes
            for (j = [-1, 1]) {
                translate([-1*mountHole1_l[0], j*mountHole1_l[1]])
                    circle(r=mountingHole/2);
                translate([-1*mountHole2_l[0], j*mountHole2_l[1]])
                    circle(r=mountingHole/2);
            }
       }
       //no fingers needed here for sd card slot
       translate([-caseSize[0]/2+material/2, 0])
        square([material, finger*3], center=true);
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
            #square([finger*17, ports_d[2]+material+sdCard_d[2]], center=true);
    }
    
}

//right();

module front() {
    difference() {
        faceA(caseSize, finger, finger, material, 0);
        translate([0, caseSize[2]/2-hifiRCA_d[2]/2-material/2])
            #square([finger*9, hifiRCA_d[2]+material], center=true);
    }
}

//front();

module back() {
    difference() {
        faceA(caseSize, finger, finger, material, 0);
    }
}

module lid() {
    difference() {
        faceB(caseSize, finger, finger, material, 0);
        translate([-brd_d[0]/2+header_d[0]/2+7, brd_d[1]/2-header_d[1]*1.5, 0])
            square([header_d[0], header_d[1]], center=true);
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
