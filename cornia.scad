// special openscad variables
$fn = 16;

// Plate slack variables:
plate_slack = 0.05;
plate_depth_slack = 0.05;

// Hotswap slack variables:
width_padding = 0.05;
height_padding = 0.07;
radius_padding = 0.5;
exit_padding = 0.5;

hotswap_height_slack = 0;

// 3 mid plate hole radius:
center_radius_slack = 0.3;
sides_radius_slack = 0.2;

stagger = [0, 2, 7, 2, -6, -6];

for(x = [0:5]){
    for(y = [0:2]){
        if(!(x == 5 && y == 2)){ // to get two 
        
        translate([18*x, y*17 + stagger[x], 0])
        // per key component
        union(){
            // plate part
            color("red")
            linear_extrude(1.3 - plate_depth_slack)
            difference(){
                
                square([18, 17]);
                translate([2.1 + 1 - plate_slack/2, 1.6 - plate_slack/2])
                square([13.8 + plate_slack, 13.8 + plate_slack]); // the x axis should mby be 13.6 not sure as the drawing is contradicting
            }

            translate([0, 0, -0.9 - plate_depth_slack])
            linear_extrude(0.9 + plate_depth_slack)
            difference(){
                square([18, 17]);
                translate([1.25 + 1, 0.75])
                square([15.5, 15.5]);
            }

            // Hotswap part

            
            difference(){
                difference(){
                    translate([0, 0, -3 - hotswap_height_slack - 0.9 - plate_depth_slack])
                    color("green")
                    linear_extrude(3 - hotswap_height_slack)
                    square([18,17]);
                   
                  
                    // translate is after roatate so we are moving the rightmost corner of the polygon from the origin (this is withough padding so padding is extra)
                    translate([11.275 + 1, 0.175, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                    rotate(90)
                    union(){       
                        linear_extrude(2.2, center = false){
                            polygon(points=[
                                [0 - width_padding, 0 - height_padding],
                                [4.65 + width_padding, 0 - height_padding],
                                [4.65 + width_padding, 3.75],
                                [6.15 + width_padding, 3.75],
                                [6.85 + width_padding, 4.4],
                                [6.85 + width_padding, 9.55 + height_padding],
                                [2.2 - width_padding, 9.55 + height_padding],
                                [2.2 - width_padding, 5.75],
                                [0 - width_padding, 5.75]
                            ]);
                        }   
                        translate([2.325, 2.275, 0])
                            cylinder(h = 10.45, r = 1.45 + radius_padding);
                        
                        color("purple")
                        translate([4.525, 7.275, 0])
                            cylinder(h = 10.45, r = 1.45 + radius_padding);
                        
                        color("orange")
                        translate([1.485 - exit_padding/2, -2.66 - height_padding, 0])
                            cube([1.68 + exit_padding, 2.67, 2.2]);
                        color("pink")
                        translate([3.685 - exit_padding/2, 9.54 + height_padding, 0])
                            cube([1.68 + exit_padding, 2.67, 2.2]);
                    
                    }   
                }
                
                
                // The 3 holes in a line on the midplate

                translate([9+1, 8.5, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                    cylinder(h = 10, r = 1.6 + center_radius_slack);

                translate([3.5+1, 8.5, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                    cylinder(h = 10, r = 0.9 + sides_radius_slack);

                translate([14.5+1, 8.5, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                    cylinder(h = 10, r = 0.9 + sides_radius_slack);
            }
        }
    }
    }
}