// special openscad variables
$fn = 32;

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

lane_width = 1.6;
move_fraction = 2.85;


stagger = [0, 2, 8, 2, -7, -7]; // max difference between neigbour columns is 9mm 

   

//mirror() use mirror to get left hand
difference(){
    union(){
        for(x = [0:5]){
            for(y = [0:2]){
                if(!(x == 5 && y == 2)){ // to get two on last pinky column
                
                    translate([18*x, y*17 + stagger[x], 0])
                    key();                  
                    
                }
            }

            if(x > 3){
                translate([18*x, stagger[x] - 2, 0])
                edge(18);
            }
            
            if(x == 0){
                translate([18*x + 16, stagger[x] + 17*3 + 2, 0])
                rotate(180)
                edge(16);

                translate([18*x + 16, stagger[x] + 17*3 + 2, 0])
                rotate(270)
                inner_corner();
                
                // buggy from here 
                //translate([18*x + 16, 17*3 + 3, 1])
                //rotate([0, 0, 270])
                //edge(stagger[x + 1] - stagger[x] - 2);
                

                translate([18*x + 16, + 17*3 + 4, 0])
                rotate(270)
                outer_corner();

                // to here 

            }
            else if(x == 5){
                color("pink")
                translate([18*x + 18 + 2, stagger[x] + 17*2 + 2, 0])
                rotate(180)
                edge(16);

                translate([18*x + 4 , stagger[x] + 17*2 + 2, 0])
                rotate(180)
                inner_corner();
                

                translate([18*x , stagger[x] + 17*2, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                color("red")
                cube([2, stagger[x-1] - stagger[x] + 17, 5.2]);
                
                translate([18*x + 4, stagger[x] + 17*2 + 2, 0])
                rotate(90)
                edge(stagger[x-1] - stagger[x] - 2 + 17);

                translate([18*x + 4, stagger[x] + 17*2 + 2 + stagger[x-1] - stagger[x] + 17, 0])
                rotate(180)
                outer_corner();

                color("pink")
                translate([18*x + 2, stagger[x-1] + 17*3 + 2, 0])
                rotate(180)
                edge(2);


                // outer edge

                translate([18*x + 22, stagger[x] + 17*2 + 2, 0])
                rotate(180)
                outer_corner();


                translate([18*x + 22, stagger[x], 0])
                rotate(90)
                edge(17*2);

                translate([18*x + 22, stagger[x] - 2, 0])
                rotate(90)
                outer_corner();

                color("pink")
                translate([18*x + 18, stagger[x] - 2, 0])
                edge(2);


                translate([18*x + 18, stagger[x], -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                cube([2, 34, 5.2]);

       
            }else{
              
                if(stagger[x - 1] > stagger[x]){
                    color("pink")
                    translate([18*x + 18, stagger[x] + 17*3 + 2, 0])
                    rotate(180)
                    edge(14);

                    translate([18*x + 4 , stagger[x] + 17*3 + 2, 0])
                    rotate(180)
                    inner_corner();
                    

                    translate([18*x , stagger[x] + 17*3, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                    color("red")
                    cube([2, stagger[x-1] - stagger[x], 5.2]);
                    
                    translate([18*x + 4, stagger[x] + 17*3 + 2, 0])
                    rotate(90)
                    edge(stagger[x-1] - stagger[x] - 2);

                    translate([18*x + 4, stagger[x] + 17*3 + 2 + stagger[x-1] - stagger[x], 0])
                    rotate(180)
                    outer_corner();

                    color("pink")
                    translate([18*x + 2, stagger[x-1] + 17*3 + 2, 0])
                    rotate(180)
                    edge(2);


                }
                else if(stagger[x + 1] > stagger[x]){
                    color("orange")
                    translate([18*x + 16, stagger[x] + 17*3 + 2, 0])
                    rotate(180)
                    edge(16);
                    

                    translate([18*x + 16, stagger[x] + 17*3 + 2, 0])
                    rotate(270)
                    inner_corner();
                    

                    translate([18*x + 16, stagger[x-1] + 17*3 + 2 + stagger[x + 1] - stagger[x] , 0])
                    rotate([0, 0, 270])
                    edge(stagger[x + 1] - stagger[x]-2);
                    

                    translate([18*x + 16, stagger[x-1] + 17*3 + 2 + stagger[x + 1] - stagger[x] + 2, 0])
                    rotate(270)
                    outer_corner();
                    
                }else{
                    color("indigo")
                    translate([18*x + 18, stagger[x] + 17*3 + 2, 0])
                    rotate(180)
                    edge(18);

                }
            }  
        }
    }
    
    // wire lanes
    union(){
        
        for (y = [0:2]){
            for(x = [0:5]){
                if(x != 5){ 
                    if(x == 4 && y == 2){
                        row_lane(x, y, true);
                    }else{
                        row_lane(x, y, false);
                    }
                   
                }else{
                    if(y != 2){
                        row_lane(x, y, true);
                    }
                    if(y == 1){
                        //translate([18 * x, 6.85 + width_padding - 0.7 - 1.68 + stagger[x], -5])
                           // cube([lane_width, 17 + , 2]);
                }
                }
                translate([18 * x - 0.1, 3.862 - exit_padding/2 + stagger[x], -5])
                            cube([lane_width, 17 + 1.68 + exit_padding, 2]);
                
                
            }
        }
    }
}


module inner_corner(){
    translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
    union(){
        translate([0, 0, 3.2])
        union(){  
            translate([0, 0, 0])
            intersection(){
                cube([2, 2, 2]);
                translate([0, 2, 0])
                rotate([0, 90, 0])
                cylinder(h=2, r=2);
            }

            translate([0, 2, 0])
            rotate(270)
            intersection(){
                cube([2, 2, 2]);
                translate([0, 2, 0])
                rotate([0, 90, 0])
                cylinder(h=2, r=2);
            }
        }

        translate([0, 0, 1])
        cube([2, 2, 2.2]);

        translate([0, 0, 1])
        rotate([0, 180, -90])
        union(){  
            translate([0, 0, 0])
            intersection(){
                cube([2, 2, 2]);
                translate([0, 2, 0])
                rotate([0, 90, 0])
                cylinder(h=2, r=2);
            }

            translate([0, 2, 0])
            rotate(270)
            intersection(){
                cube([2, 2, 2]);
                translate([0, 2, 0])
                rotate([0, 90, 0])
                cylinder(h=2, r=2);
            }
        }
    }
}

module outer_corner(){
    translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
    union(){
        translate([2, 2, 3.2])
        rotate([0, 0, 180])
        intersection(){
            sphere(r = 2);
            cube([4, 4, 4]);
        }

        color("blue")
        translate([0, 2, 3.2])
        rotate([90, 90, 0])
        intersection(){
            cube([2.2, 2, 2]);
            translate([0, 2, 0])
            rotate([0, 90, 0])
            cylinder(h=2.3, r=2);
        }


        translate([2, 2, 1])
        rotate([0, 180, 90])
        intersection(){
            sphere(r = 2);
            cube([4, 4, 4]);
        }
    }
}  
  

module edge(length){
    translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
    union(){
        translate([0, 0, 3.2])
        intersection(){
            cube([length, 2, 2]);
            translate([0, 2, 0])
            rotate([0, 90, 0])
            cylinder(h=length, r=2);
        }


        translate([0, 0, 1])
        cube([length, 2, 2.2]);

        translate([0, 2, -1])
        rotate([90, 0, 0])
        intersection(){
            cube([length, 2, 2]);
            translate([0, 2, 0])
            rotate([0, 90, 0])
            cylinder(h=length, r=2);
        }
    }
}



// Int stagger_index is the index of the key column
// Boolean end of loop and keyboard
module row_lane(x, y, end){
    if(end){
        translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
        //translate([0, 0, 5])
        linear_extrude(2)
        polygon([
            [2 + x*18, 17*y + 13 + stagger[x]],
            [14 + x*18, 17*y + 13 + stagger[x]],     
            [14 + x*18, 17*y + 13 + lane_width + stagger[x]],
            [2 + x*18, 17*y + 13 + lane_width + stagger[x]]
        ]);
    }else{
        translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
        //translate([0, 0, 5])
        linear_extrude(2)
        if (x != 0){
            polygon([
                [2 + x*18, 17*y + 13 + stagger[x]],
                [16.5 + x*18, 17*y + 13 + stagger[x] + (stagger[x + 1] - stagger[x])/move_fraction],
                [2.01 + (x+1)*18, 17*y + 13 + stagger[x+1]],   
                [2.01 + (x+1)*18 + (stagger[x] - stagger[x+1])/8, 17*y + 13 + lane_width + stagger[x+1]],      
                [16.5 + x*18 + (stagger[x] - stagger[x+1])/8, 17*y + 13 + lane_width + stagger[x] + (stagger[x + 1] - stagger[x])/move_fraction],
                [2 + x*18 + (stagger[x - 1] - stagger[x])/8, 17*y + 13 + lane_width + stagger[x]]
            ]);
        }else{
            polygon([
                [2 + x*18, 17*y + 13 + stagger[x]],
                [16.5 + x*18, 17*y + 13 + stagger[x] + (stagger[x + 1] - stagger[x])/move_fraction],
                [2.01 + (x+1)*18, 17*y + 13 + stagger[x+1]],   
                [2.01 + (x+1)*18 + (stagger[x] - stagger[x+1])/8, 17*y + 13 + lane_width + stagger[x+1]],      
                [16.5 + x*18 + (stagger[x] - stagger[x+1])/8, 17*y + 13 + lane_width + stagger[x] + (stagger[x + 1] - stagger[x])/move_fraction],
                [2 + x*18, 17*y + 13 + lane_width + stagger[x]]
            ]);
        }
    }
}



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




//module edge(length){
  //  difference(){
    //    cube([length, 2, 5.2]);
      //  translate([-0.01, -1.415, 4.612])
        //
//        rotate([-45, 0, 0])
//        color("black")
//        cube([length + 0.02, 2, 3]);
//    }
//}


thumbkey_angles = [25, 35, 45]; // must be in increasing order from left to right

// new code for thumb cluster
translate([0, 0, 0])
//translate([18, -20.5, 0])
union(){
    
    // THUMB KEY 0
    // translate top right corner to origin
    translate([
            -(cos(atan(17/18) + thumbkey_angles[0]) * sqrt(17^2 + 18^2)),
            -(sin(atan(17/18) + thumbkey_angles[0]) * sqrt(17^2 + 18^2)), 
            0
    ])
    rotate(thumbkey_angles[0])
    
    union(){
        color("indigo")
        key();
        // Fils gap between key 0 and 1
        color("marine")
        translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
        linear_extrude(5.2)
                        polygon(points=[
                            [0, 0],
                            [0, 17],
                            [
                            -sin((180 - (thumbkey_angles[1] - thumbkey_angles[0]))/2) * (sin((thumbkey_angles[1] - thumbkey_angles[0])) * 17)/sin((180 - (thumbkey_angles[1] - thumbkey_angles[0]))/2), 
                            17 - cos((180 - (thumbkey_angles[1] - thumbkey_angles[0]))/2) * (sin((thumbkey_angles[1] - thumbkey_angles[0])) * 17)/sin((180 - (thumbkey_angles[1] - thumbkey_angles[0]))/2)
                            ]
                        ]);
    }
    
    
    // THUMB KEY 1
    // apply key 0 translate to make bottom right corner at same place as key 0 bottom left corner
    translate([
        -(cos(atan(17/18) + thumbkey_angles[0]) * sqrt(17^2 + 18^2)),
        -(sin(atan(17/18) + thumbkey_angles[0]) * sqrt(17^2 + 18^2)), 
        0
    ])
    // translate bottom right corner to origin
    translate([
        -(cos(thumbkey_angles[1]) * 18),
        -(sin(thumbkey_angles[1]) * 18),
        0
    ])
    rotate(thumbkey_angles[1])
   
    union(){
        color("orange")
        key();
        // Fils gap between key 1 and 2
        color("marine")
        translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
        linear_extrude(5.2)
                        polygon(points=[
                            [0, 0],
                            [0, 17],
                            [
                            -sin((180 - (thumbkey_angles[2] - thumbkey_angles[1]))/2) * (sin((thumbkey_angles[2] - thumbkey_angles[1])) * 17)/sin((180 - (thumbkey_angles[2] - thumbkey_angles[1]))/2), 
                            17 - cos((180 - (thumbkey_angles[2] - thumbkey_angles[1]))/2) * (sin((thumbkey_angles[2] - thumbkey_angles[1])) * 17)/sin((180 - (thumbkey_angles[2] - thumbkey_angles[1]))/2)
                            ]
                        ]);
    }
        
        
    // THUMB KEY 2
    
    // apply key 0 translate 
    translate([
        -(cos(atan(17/18) + thumbkey_angles[0]) * sqrt(17^2 + 18^2)),
        -(sin(atan(17/18) + thumbkey_angles[0]) * sqrt(17^2 + 18^2)), 
        0
    ])
    // apply key 1 translate
    translate([
        -(cos(thumbkey_angles[1]) * 18),
        -(sin(thumbkey_angles[1]) * 18),
        0
    ])
    // move bottom right corner to origin
    translate([
        -(cos(thumbkey_angles[2]) * 18),
        -(sin(thumbkey_angles[2]) * 18),
        0
    ])
    rotate(thumbkey_angles[2])
    color("aqua")
    key();
}


















