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

columns = 5; // zero indexed so 5 for 6 and 4 for 5 // colums is len(stagger) but it did not work for some reason so update accordingly
two_key_last_column = true; // might use for setting last row to be with or without key

// Stagger configuration list:
    // max difference between neigbour columns is 9mm for wire lanes to work 
    // minimum difference between neigbouring columns is 2mm if it's less than 2mm the border does not line up correctly
        // can fixed by removing inner_corner and just make the edges overlap (MIGHT DO LATER)
stagger = [0, 2, 8, 3, -7, -9]; 

   
// side_padding decides the padding between the rounded border and the key on the right as each key module is shifted towards the left
side_padding = 2.1; // for easy prototyping // should mby be 2.1 FYI (this is for centering the key)

//mirror() // use mirror to get left hand (besides thumb cluster)
difference(){
    union(){
        
        // BOTTOM BORDER OF PINKY ROWS
        if (columns == 5){
            if (stagger[4] > stagger[5]){
                // last pinky column is lower than the first (normal configuration)
                translate([18*4 + 16, stagger[4] - 2, 0])
                inner_corner();

                translate([18*4, stagger[4] - 2, 0])
                edge(16);

                // connecting wall:
                translate([18*(4) + 16, stagger[4] - 4, 0])
                translate([0, 2, 0])
                rotate(270)
                edge(stagger[4] - stagger[5] - 2);
                
                // Last column border:
                translate([18*5, stagger[5] - 2, 0])
                edge(18);

                translate([18*5 - 2, stagger[5] - 2, 0])
                outer_corner();
            }
            else if (stagger[4] < stagger[5]){
                // last pinky is higher up than first pinky column (strange unusual configuration)
                translate([18*4 + 18 + side_padding, stagger[4] - 2, 0])
                translate([2, 0, 0])
                rotate(90)
                outer_corner();

                translate([18*4, stagger[4] - 2, 0])
                edge(18 + side_padding);

                // padding to make center key:
                translate([18*(4) + 18, stagger[4], 0])
                translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                color("indigo")
                cube([side_padding, stagger[5] - stagger[4], 5.2]);

                // connecting wall:
                translate([18*(4) + 18 + side_padding, stagger[4], 0])
                translate([2, 0, 0])
                rotate(90)
                edge(stagger[5] - stagger[4] - 2);

                // Last column border:
                translate([18*5 + 2 + side_padding, stagger[5] - 2, 0])
                edge(14);

                translate([18*5 + side_padding, stagger[5] - 2, 0])
                translate([2, 0, 0])
                rotate(90)
                inner_corner();


            }
            else{
                // the last two have the same stagger (Fairly normal configuration)
                translate([18*4, stagger[4] - 2, 0])
                edge(18);

                translate([18*5, stagger[5] - 2, 0])
                edge(18);
            }
        }
        else{
            // only 5 columns (zero indexed so columns is 4)
            translate([18*4, stagger[4] - 2, 0])
            edge(18);
        }


        // LOOP FOR PLACING THE KEYS AND OUTER BORDER         
        for(x = [0:columns]){
            for(y = [0:2]){
                if(!(x == columns && y == 2 && two_key_last_column)){ // to get two on last pinky column
                    translate([18*x, y*17 + stagger[x], 0])
                    key();                  
                }
            }

            // ##########################################
            // ###### LEFT BRIDGE ALONG TOP BORDER ######
            // ##########################################
            if (x != 0){
                if (stagger[x] == stagger[x - 1]){
                    // case where previous column and current column were the same
                    if (x == columns && two_key_last_column){
                        translate([18*x + side_padding, stagger[x] + 17*2, 0])
                        translate([2, 2, 0]) // translate to origin
                        rotate(180)
                        inner_corner();

                        translate([18*x, stagger[x] + 17*2, 0])
                        translate([9, 2, 0]) // translate to origin
                        rotate(180)
                        edge(7-side_padding);

                        // padding
                        translate([18*(x), stagger[x] + 17 * 2, 0])
                        translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                        color("indigo")
                        cube([side_padding, stagger[x-1] - stagger[x] + 17, 5.2]);

                        // need to add wall here aswell as it's only two keys for last column so a big stretch between

                        // connecting wall shows only if stagger is more than 2mm
                        translate([18*x + side_padding, stagger[x] + 17*2 + 2, 0])
                        translate([2, 0, 0])
                        rotate(90)
                        edge(15);
                    }
                    else{
                        translate([18*x, stagger[x] + 17*3, 0])
                        translate([9, 2, 0]) // translate to origin
                        rotate(180)
                        color("blue")
                        edge(9);

                    }
                }
                else if (stagger[x] < stagger[x-1]){
                    // case where current column where lower than the previous column
                    
                    if (x == columns && two_key_last_column){
                        // case when two key on last column
                        translate([18*x + side_padding, stagger[x] + 17*2, 0])
                        translate([2, 2, 0]) // translate to origin
                        rotate(180)
                        color("blue")
                        inner_corner();


                        translate([18*x + side_padding, stagger[x] + 17*2, 0])
                        translate([9-side_padding, 2, 0]) // translate to origin
                        rotate(180)
                        edge(9-2-side_padding);

                        translate([18*x + side_padding, stagger[x] + 17*2 + 2, 0])
                        translate([2, 0, 0])
                        rotate(90)
                        edge(stagger[x - 1] - stagger[x] - 2 + 17);


                        // padding border (pointing to the right)
                        translate([18*(x), stagger[x] + 17 * 2, 0])
                        translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                        color("indigo")
                        cube([side_padding, stagger[x-1] - stagger[x] + 17, 5.2]);

                    }
                    else{
                        // normal case 
                        translate([18*x + side_padding, stagger[x] + 17*3, 0])
                        translate([2, 2, 0]) // translate to origin
                        rotate(180)
                        inner_corner();


                        translate([18*x + side_padding, stagger[x] + 17*3 + 2, 0])
                        translate([9-side_padding, 0, 0])
                        rotate(180)
                        edge(9-2-side_padding);

                        // connecting wall shows only if stagger is more than 2mm
                        translate([18*x + side_padding, stagger[x] + 17*3 + 2, 0])
                        translate([2, 0, 0])
                        rotate(90)
                        edge(stagger[x - 1] - stagger[x] - 2);


                        // padding border (pointing to the right)
                        translate([18*(x), stagger[x] + 17 * 3, 0])
                        translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                        color("indigo")
                        cube([side_padding, stagger[x-1] - stagger[x], 5.2]);
                    }


                }
                else {
                    // case where previous column was lower than the current column
                    if (x == columns && two_key_last_column && stagger[x-1] > (stagger[x] - 17)){
                        translate([18*x + side_padding, stagger[x] + 17*2, 0])
                        translate([2, 2, 0]) // translate to origin
                        rotate(180)
                        inner_corner();

                        // connecting vertical border

                        translate([18*x + side_padding, stagger[x] + 17*2 + 2, 0])
                        translate([2, 0, 0]) // translate to origin
                        rotate(90)
                        edge(17 - abs(stagger[x] - stagger[x - 1]) - 2);

                        echo("abs abs: ", abs(stagger[x] - stagger[x - 1]));

                        translate([18*x, stagger[x] + 17*2, 0])
                        translate([9, 2, 0]) // translate to origin
                        rotate(180)
                        edge(7 - side_padding);
                    }
                    else{
                        translate([18*x - 2, stagger[x] + 17*3, 0])
                        translate([0, 2, 0]) // translate to origin
                        rotate(-90)
                        outer_corner();

                        translate([18*x, stagger[x] + 17*3, 0])
                        translate([9, 2, 0]) // translate to origin
                        rotate(180)
                        edge(9);
                    }
                    
                }


            }
            
            // ###########################################
            // ###### RIGHT BRIDGE ALONG TOP BORDER ######
            // ###########################################
            if (x != 5){
                if (stagger[x] == stagger[x + 1]){
                    if (x == columns - 1 && two_key_last_column){
                        translate([18*x + 16 + 2 + side_padding, stagger[x] + 17*3, 0])
                        translate([2, 2, 0]) // translate to origin
                        rotate(180)
                        outer_corner();

                        translate([18*x + 16 + side_padding, stagger[x] + 17*3, 0])
                        translate([2, 2, 0]) // translate to origin
                        rotate(180)
                        edge(9+side_padding);
                    }
                    else{
                        translate([18*x + 16, stagger[x] + 17*3, 0])
                        translate([2, 2, 0]) // translate to origin
                        rotate(180)
                        edge(9);

                    }

                }
                if (stagger[x] < stagger[x + 1]){
                    // current is lower than next
                    if (x == columns-1 && two_key_last_column && stagger[x] > (stagger[x+1] - 17)){

                        translate([18*x + 16 + 2 + side_padding, stagger[x] + 17*3, 0])
                        translate([2, 2, 0]) // translate to origin
                        rotate(180)
                        color("pink")
                        outer_corner();

                        translate([18*x + 16, stagger[x] + 17*3, 0])
                        translate([2 + side_padding, 2, 0]) // translate to origin
                        rotate(180)
                        edge(9 + side_padding);

                        // padding cube
                        translate([18*(x) + 18, stagger[x+1] + 17*2, 0])
                        translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                        color("indigo")
                        cube([side_padding, 17 - (stagger[x+1] - stagger[x]), 5.2]);

                        // connecting wall when stagger is greater than 2mm 
                        // in cases where outer edge points to the left
//                        translate([18*x + 16, stagger[x] + 17*3 + 2, 0])
  //                      translate([0, stagger[x+1] - stagger[x] - 2, 5]) // move to origin
    //                    rotate(-90)
      //                  color("orange")
        //                edge(stagger[x+1] - stagger[x] - 2);
                        
                    }else{
                        translate([18*x + 16, stagger[x] + 17*3, 0])
                        translate([0, 2, 0]) // translate to origin
                        rotate(-90)
                        color("blue")
                        inner_corner();


                        translate([18*x + 16, stagger[x] + 17*3, 0])
                        translate([0, 2, 0]) // translate to origin
                        rotate(180)
                        edge(7);

                        // connecting wall when stagger is greater than 2mm 
                        // in cases where outer edge points to the left
                        translate([18*x + 16, stagger[x] + 17*3 + 2, 0])
                        translate([0, stagger[x+1] - stagger[x] - 2, 0]) // move to origin
                        rotate(-90)
                        edge(stagger[x+1] - stagger[x] - 2);
                    }

                }
                if (stagger[x] > stagger[x + 1]){
                    translate([18*x + 16 + 2 + side_padding, stagger[x] + 17*3, 0])
                    translate([2, 2, 0]) // translate to origin
                    rotate(180)
                    color("pink")
                    outer_corner();

                    translate([18*x + 16 + side_padding, stagger[x] + 17*3, 0])
                    translate([2, 2, 0]) // translate to origin
                    rotate(180)
                    edge(9 + side_padding);

                }
            }


            // #################################################
            // ###### END BORDER AND PADDING TO THE RIGHT ######
            // #################################################
            if (x == columns){
                key_count = (two_key_last_column) ? 2 : 3; // turnary operator - variables can't be changed in if in openSCAD 


                // padded cube
                translate([18*(x+1), stagger[x], 0])
                translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
                color("indigo")
                cube([side_padding, 17*key_count, 5.2]);

                // top border along padded cube
                translate([18*x + 16, stagger[x] + 17*key_count, 0])
                translate([2 + side_padding, 2, 0]) // translate to origin
                rotate(180)
                edge(9 + side_padding);
                
                // upper outer corner
                translate([18*(x+1) + side_padding, stagger[x] + 17*key_count, 0])
                translate([2, 2, 0])
                rotate(180)
                outer_corner();

                // long side edge
                translate([18*(x+1) + side_padding, stagger[x], 0])
                translate([2, 0, 0]) // translate to oriting
                rotate(90)
                edge(17*key_count);

                // bottom outer corner
                translate([18*(x+1) + side_padding, stagger[x] - 2, 0])
                translate([2, 0, 0])
                rotate(90)
                outer_corner();

                // bottom boorder along padded cube
                translate([18*x + 16, stagger[x] - 2, 0])
                translate([2, 0, 0]) // translate to origin
                edge(side_padding);

                         
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
  

// side: 0 = top; 1 = right; 2 = bottom; 3 = left; // part of future update to readability and maintainability of code
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


// ###########################
// ###### THUMB CLUSTER ######
// ###########################

thumbkey_angles = [15, 25, 40]; // must be in increasing order from left to right

thumb_translate = [25, 1.2, 0]; // location of the thumb cluster 
translate(thumb_translate) 
//translate([0, 0, 0])
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
        translate([18, 17, 0]) // translate to origin after rotate of switch for easy wire routing
        rotate(180)
        key();
        // Fils gap between key 0 and 1
        color("aqua")
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
        translate([0, -2, 0])
        edge(18);
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
        translate([18, 17, 0]) // translate to origin after rotate of switch for easy wire routing
        rotate(180)
        key();
        // Fils gap between key 1 and 2
        color("aqua")
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
        translate([0, -2, 0])
        edge(18);
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
    union(){
        color("pink")
        translate([18, 17, 0]) // translate to origin after rotate of switch for easy wire routing
        rotate(180)
        key();
        
        translate([0, -2, 0])
        edge(18);
        
        translate([-2, -2, 0])
        outer_corner();
        
        translate([-2, 17, 0])
        rotate(270)
        edge(17);
        
        translate([-2, 19, 0])
        rotate(270)
        outer_corner();
    }
}



// ###########################################################
// ###### fill and border combine thumbcluster and main ######
// ###########################################################

overlap_length = 0;
calc_angle = atan(abs((-(cos(thumbkey_angles[0]) * 17) + thumb_translate[1]) - (stagger[4])) /
            abs((sin(thumbkey_angles[0]) * 17 + thumb_translate[0]) - 18*4));

angle = ((stagger[4] - 2) < -(cos(thumbkey_angles[0]) * 19) + thumb_translate[1]) ? -calc_angle : calc_angle;
echo("blue loc: ", (stagger[4] - 2));
//echo("Pink loc: ", sin(thumbkey_angles[0]) * 19 + thumb_translate[0]);
echo("Pink loc: ", -(cos(thumbkey_angles[0]) * 19) + thumb_translate[1]);
echo(angle)
echo(calc_angle)
//translate(sin(thumbkey_angles[0]) * 17, cos(thumbkey_angles[0]) * 17, 0)
translate([sin(thumbkey_angles[0]) * 17 - overlap_length, -(cos(thumbkey_angles[0]) * 17), 0])
translate(thumb_translate) 
//rotate(90 - atan(abs((sin(thumbkey_angles[0]) * 19 + thumb_translate[0]) - 18*4)/
  //                  abs((-(cos(thumbkey_angles[0]) * 19) + thumb_translate[1]) - (stagger[4] - 2))))

rotate(angle)
translate([0, -2, 0])
color("red")
edge(sqrt(((sin(thumbkey_angles[0]) * 17 + thumb_translate[0]) - 18*4)^2 + 
          ((-(cos(thumbkey_angles[0]) * 17) + thumb_translate[1]) - (stagger[4]))^2)
    + overlap_length
);

//translate([sin(thumbkey_angles[0]) * 17 + thumb_translate[0], -(cos(thumbkey_angles[0]) * 17) + thumb_translate[1], 0])
//cube([2, 2, 2]);


//translate([18*4, stagger[4], 0])
//cube([2, 2, 2]);




// POLYGON BETWEEN THUMBCLUSTER AND MAIN KEYBOARD PART TO FILL IT OUT
translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
color("gray")
linear_extrude(5.2)
    polygon(points=[
        [sin(thumbkey_angles[0]) * 17 + thumb_translate[0], -(cos(thumbkey_angles[0]) * 17) + thumb_translate[1]],
        [18*4, stagger[4]],
        [18*4, stagger[3]],
        [18*3, stagger[3]],
        [18*3, stagger[2]],
        [18*2, stagger[2]],
        [18*2, stagger[1]],
        [18, stagger[1]],
        [thumb_translate[0], thumb_translate[1]]
    ]);



translate([0, 0, -3.001 - hotswap_height_slack - 0.9 - plate_depth_slack])
color("#eee")
linear_extrude(5.2)
    polygon(points=[
        [thumb_translate[0], thumb_translate[1]], 
        [18, stagger[1]],
        [18, stagger[0]]

    ]);
