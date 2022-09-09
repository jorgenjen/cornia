plate_slack = 0;
plate_depth_slack = 0;

// plate essentially
color("red")
linear_extrude(1.3 - plate_depth_slack)
difference(){
    
    square([18, 17]);
    translate([2.1 - plate_slack/2, 1.6 - plate_slack/2])
    square([13.8 + plate_slack, 13.8 + plate_slack]); // the x axis should mby be 13.6 not sure as the drawing is contradicting
}

translate([0, 0, -0.9 - plate_depth_slack])
linear_extrude(0.9 + plate_depth_slack)
difference(){
    square([18, 17]);
    translate([1.25, 0.75])
    square([15.5, 15.5]);
}

// Hotswap part

hotswap_height_slack = 0;
//difference(){
translate([0, 0, -3 - hotswap_height_slack - 0.9 - plate_depth_slack])
color("green")
linear_extrude(3 - hotswap_height_slack)
square([18,17]);



// old code to be merged

width_padding = 0; //0.05;
height_padding = 0; //0.07;
radius_padding = 0; //0.5;
exit_padding = 0; //0.5;

      

//translate([4, 3, -3.91 - plate_depth_slack])  

// translate is after roatate so we are moving the rightmost corner of the polygon from the origin (this is withough padding so padding is extra)
translate([0, 0, 0])
rotate(90)
union(){       
    linear_extrude(2.2, center = false){
        polygon(points=[
            [0 - width_padding, 0 - height_padding],
            [4.65 + width_padding, 0 - height_padding],
            [4.65 + width_padding, 3.75],
            [6.85 + width_padding, 3.75],
            [6.85 + width_padding, 9.55 + height_padding],
            [2.2 - width_padding, 9.55 + height_padding],
            [2.2 - width_padding, 5.75],
            [0 - width_padding, 5.75]
        ]);
    }   
    translate([2.325, 2.275, 0])
        cylinder(h = 10.45, r = 1.45 + radius_padding, $fn = 360);

    translate([4.525, 7.275, 0])
        cylinder(h = 10.45, r = 1.45 + radius_padding, $fn = 360);
    
    color("orange")
    translate([1.485 - exit_padding/2, -2.19 - height_padding, 0])
        cube([1.68 + exit_padding, 2.2, 2.2]);
    color("pink")
    translate([3.685 - exit_padding/2, 9.54 + height_padding, 0])
        cube([1.68 + exit_padding, 2.2, 2.2]);
    
        //translate([3.485 - exit_padding/2, 13.2, 1.3])
          //  cube([1.68 + exit_padding, 4, 3]);
}
//}  
    
    
    