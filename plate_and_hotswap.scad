plate_slack = 0;
plate_depth_slack = 0;

// plate essentially
color("red")
linear_extrude(1.3 - plate_depth_slack)
difference(){
    
    square([18, 17]);
    translate([2.2 - plate_slack/2, 1.6 - plate_slack/2])
    square([13.6 + plate_slack, 13.8 + plate_slack]); // the x axis might be 13.8 aswell not sure drawing is contradictive
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

translate([0, 0, -3 - hotswap_height_slack - 0.9 - plate_depth_slack])
color("green")
linear_extrude(3 - hotswap_height_slack)
square([18,17]);



// old code to be merged

width_padding = 0; //0.05;
height_padding = 0; //0.07;
radius_padding = 0; //0.5;
exit_padding = 0; //0.5;


//translate([])
linear_extrude(2.2, center = false){
    polygon(points=[
        [0, 0],
        [4.65, 0],
        [4.65, 3.75],
        [6.85, 3.75],
        [6.85, 9.55],
        [2.2, 9.55],
        [2.2, 5.75],
        [0, 5.75]
    ]);
}
        
            
            
union(){
        //translate([5.685 - exit_padding/2, -0.1, 1.3])
          //  cube([1.68 + exit_padding, 4, 3]);
        //translate([3.485 - exit_padding/2, 13.2, 1.3])
          //  cube([1.68 + exit_padding, 4, 3]);
        
        translate([2.325, 2.275, 0])
            cylinder(h = 10.45, r = 1.45 + radius_padding, $fn = 360);

        translate([4.525, 7.275, 0])
            cylinder(h = 10.45, r = 1.45 + radius_padding, $fn = 360);
    }