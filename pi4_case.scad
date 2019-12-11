//use <../finger_joint_box/finger_joint_box.scad>
//use </Users/aaronciuffo/Documents/Hobby/OpenSCAD/finger_joint_box/finger_joint_box.scad>
use <finger_joint_box.scad>
use <raspberrypi.scad>


material = 2.3;
over = 0.5;
finger = 5;
piSize = [85, 56.3, 27.2];
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
ports_d = [0, 53, 17];

//hifi berry dimensions
//RCA Jacks
hifiRCA_d = [29, 9.5,14.2];

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
        zMult = 4; // z height multiplyer for the sd card size
        echo("SD Card Slot height: ", sdCard_d[2]*zMult);
        faceC(caseSize, finger, finger, material);
        // remove a slot for sd card access
        translate([0, -caseSize[2]/2 + (sdCard_d[2]*zMult + material)/2 , 0])
            square([finger*3, sdCard_d[2]*zMult + material], center=true);
    }
}

module right() {
    difference() {
        faceC(caseSize, finger, finger, material);
        // cut hole for usb, network port access
        //FIXME - this should be based on PI SIZE not CASE SIZE
        translate([0, -caseSize[2]/2+ports_d[2]/2+material/2, 0])
            square([ports_d[1], ports_d[2]+material], center=true);
    }
    
}

module front() {
    difference() {
        faceA(caseSize, finger, finger, material, 0);
        // possibly make the opening 6 fingers wide 
        //translate([piSize[0]/2-hifiRCA_d[0]/2-27.5, caseSize[2]/2-hifiRCA_d[2]/2-material/2])
        translate([0, caseSize[2]/2-hifiRCA_d[2]/2-material/2])
            //#square([hifiRCA_d[0], hifiRCA_d[2]+material], center=true);
            #square([finger*7, hifiRCA_d[2]+material], center=true);
    }
}

//front();

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
}


