// GoPro fully customizable arm mount
// by MBRAMI
// Version 1.1 - JAN 2021

/* [Settings] */

//Arm length
length=0;//[0:0.1:200]

//Arm twist along length axis
twist=0;//[0:0.1:90]

//Arm bend along axis normal
bend=0;//[0:0.1:100]


/* [Hidden] */
th= 2.90;   //Thickness of solid tabs
sp = 3.10;  //Thickness of gaps
sp_g = 10; // Thickness of gap for the host in mm
th_g = 2.5; 
w = 15.14;  //Width of mount base
l = 13.14;  //length of mount base

$fn=72;

module tab(hasNut){
    hasNut = false;
    
    /*
    this module generates any tab (with or without M5 nut slot)
    usage:
      tab(); -> generates a simple tab with origin centered at the middle of the hole
      tab(true); -> generates the tab with nut slot
    */
    
    //render() //enable if running animation, not needed otherwise
    difference(){ 
        //Putting together base and curved end of the tab
        union(){
            //this is the base
            translate([0,0,-5])
                cube([l,th, 10], center=true);
            //this is the round end
            rotate([90,0,0])
                cylinder(h=th, d=l, $fn=72, center=true);
            //Additional feature for the tab that holds the nut
            if (hasNut == true){
                translate([0,-(3.8+th)/2,0])
                    rotate([90,0,0])
                        cylinder(h=3.8, r1=l/2, r2=11.8/2,center=true, $fn=72);
            };
        };
        //subtracting hexagonal slot for the nut
        translate([0,-(3.8+th)/2,0])
            rotate([90,0,0])
                cylinder(h=3.8,d=9.3,center=true, $fn=6);
        //subtracting M5 hole for the bolt
        rotate([90,0,0])
            cylinder(h=20,d=5,center=true, $fn=72);
    };   
};


module host(){
    //host is the 3-tabbed part of the connector
    
    //host base
    translate([0,0,-10+th/2])cube([l, w, th], center=true);
    //generating 3 tabs with 2*sp spacing
    translate([0,-2*sp,0])tab(true);
    translate([0,0,0])tab();
    translate([0,2*sp,0])tab();
};

module guest(){
    // guest is the 2-tabbed part of the connector
    //guest base
    translate([0,0,-10+th_g/2])cube([l, w, th_g], center=true);
    //generating 2 tabs with sp spacing
    translate([0,-sp_g/2- th_g/2,0])tab();
    translate([0,sp_g/2+th_g/2,0])tab();
};


module arm(length, twist, bend){
    //arm is the final module to be called
    
    //Constraints for twist and bend angles
    tw = twist>90?90:twist;
    bn = bend>100?100:bend; 
    
    //
    hull(){
         //I need to cut the tabs from the base of the host, otherwise the "hull" will make them convex
        rotate([0,180,0])
            translate([0,0,10])
                difference(){
                    host();
                    translate([0,0,3])
                        cube([l+10,w+10,20], center= true);
                };
         //I need to cut the tabs from the base of the guest as well        
        rotate([0,0,twist])
            translate([0,0,length+10])
                rotate([0,bend,0])
                    translate([0,0,13])
                        difference(){
                            host();  
                            translate([0,0,3])
                                cube([l+10,w+10,20], center= true);
                        };
    };
    
    //Now I can re-add both the guest and the host tabs
    rotate([0,180,0])
        translate([0,0,10])
            guest();
    //And I can apply twisting and bending to the host
    rotate([0,0,twist])
        translate([0,0,length+10])
            rotate([0,bend,0])
                translate([0,0,13])
                    host();
};


//Animation
/*
if ($t < 0.25){
    color("yellow")arm(70*sin($t*4*90)^2, 0, 0);
} else if ($t>=0.25 && $t < 0.5){
    color("yellow")arm(70*sin($t*4*90)^2, 90*sin($t*4*180), 0);
    } else if ($t>=0.5){
    color("yellow")arm(70*sin($t*2*180)^2, 90*sin($t*4*180), 100*sin($t*2*360));
        };
*/

arm(length, twist, bend);

