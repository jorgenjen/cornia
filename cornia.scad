// special openscad variables
$fn = 16;

// Plate slack variables:
plate_slack = 0.05;
plate_depth_slack = 0.05;

// Hotswap slack variables:
width_padding = 0.25;
height_padding = 0.25;
exit_padding = 0.5;
ledge_width = 0.5;

hotswap_height_slack = 0;

// 3 mid plate hole radius:
center_radius_slack = 0.35;
sides_radius_slack = 0.25;

// wire lanes variables

lane_width = 1.8;



stagger = [0, 2, 9, 2, -8, -8]; // max difference between neigbour columns is 10mm 
//difference(){
    union(){
    for(x = [0:5]){
        for(y = [0:2]){
            if(!(x == 5 && y == 2)){ // to get two 
            
                translate([18*x, y*17 + stagger[x], 0])
                key();
                
            }
        }
    }
    }

    move_fraction = 3;
    // wire lanes
    union(){
        for (y = [0:1]){
            for(x = [0:5]){
                if(x != 5 ){ 
                    translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                    //translate([0, 0, 5])
                    linear_extrude(2)
                    polygon([
                        [2 + x*18, 17*y + 13 + stagger[x]],
                        [16.5 + x*18, 17*y + 13 + stagger[x] + (stagger[x + 1] - stagger[x])/move_fraction],
                        [2.01 + (x+1)*18, 17*y + 13 + stagger[x+1]],   
                        [2.01 + (x+1)*18, 17*y + 13 + lane_width + stagger[x+1]],      
                        [16.5 + x*18, 17*y + 13 + lane_width + stagger[x] + (stagger[x + 1] - stagger[x])/move_fraction],
                        [2 + x*18, 17*y + 13 + lane_width + stagger[x]]
                    ]);
                    
              
                }else{
                    if(y == 0){
                        translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                        //translate([0, 0, 5])
                        linear_extrude(2)
                        polygon([
                            [2 + x*18, 13 + stagger[x]],
                            [14 + x*18, 13 + stagger[x]],     
                            [14 + x*18, 13 + lane_width + stagger[x]],
                            [2 + x*18, 13 + lane_width + stagger[x]]
                        ]);
                    }
                }
            }
        }
    }
//}




module key(){
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
                        [5.9 + width_padding, 3.75],
                        [6.85 + width_padding, 4.6],
                        [6.85 + width_padding, 9.55 + height_padding],
                        [2.2 - width_padding, 9.55 + height_padding],
                        [2.2 - width_padding, 5.75],
                        [0 - width_padding, 5.75]
                    ]);
                }   
            
                linear_extrude(4.2, center = false){
                    polygon(points=[
                        [4.65 + width_padding, 3.75 + ledge_width* 1.5],
                        [6.85 - ledge_width + width_padding, 3.75 + ledge_width * 1.5],
                        [6.85 - ledge_width + width_padding, 9.55 - ledge_width + height_padding],
                        [2.2 + ledge_width - width_padding, 9.55 - ledge_width + height_padding],
                        [2.2 + ledge_width - width_padding, 5.75 + ledge_width]

                    ]);
                } 

                linear_extrude(4.2, center = false){
                    polygon(points=[
                        [0 + ledge_width - width_padding, 0 + ledge_width - height_padding],
                        [4.65 - ledge_width + width_padding, 0 + ledge_width - height_padding],
                        [4.65 - ledge_width + width_padding, 3.75 - ledge_width],
                        [2.2 - width_padding, 5.75 - ledge_width * 1.5],
                        [0 + ledge_width - width_padding, 5.75 - ledge_width * 1.5]

                    ]);
                } 
                
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
        color("indigo")
        translate([3.5+1, 8.5, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
            cylinder(h = 10, r = 0.9 + sides_radius_slack);
        
        // A cube to subtract to make the print quality better as the hole is too close to the hotswap part
        color("red")
        translate([3.6, 7, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
            cube([1.8, 1, 2.2]);
        

        
        translate([14.5+1, 8.5, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
            cylinder(h = 10, r = 0.9 + sides_radius_slack);
    }
}


//translate([0, -2, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
//edge(18);

module edge(length){
    difference(){
        cube([length, 2, 5.2]);
        translate([-0.01, -1.415, 4.612])
        rotate([-45, 0, 0])
        color("black")
        cube([length + 0.02, 2, 3]);
    }
}

