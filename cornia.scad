use <modules/key_unit.scad>
// use <modules/column_gap_filler_methods.scad>

/* Creates the key grid/well the keys used by all fingers besides the thumb 
    * stagger: stagger of the key columns -- offset along y-axis where each column starts at the bottom [list]
    * well_depth: depth offset of each column -- used to create key well (offset along z-axis) [list]
    * roll_angles: roll angle of each column -- rotation around the y-axis [list]
    * pitch_angles: pitch angle of each key -- rotation around the x-axis [2D list]
    * yaw_angles: yaw angle of each column -- rotation around the z-axis [list]
    * last_col_key_count: number of keys in the last column -- 0 no column 1/2/3 number of keys in column [int]
    * spacing_x: keycap spacing x -- x-axis [int]
    * spacing_y: keycahttps://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/p spacing y -- y-axis [int]
    * key_module_height: height of the key module -- z-axis [int]
    * plate2cap_dist: distance from the plate to top of keycap -- z-axis [int]

    * Default values are set for each param but each can be ovverriden
*/


module main_keys(
        stagger = [0, 2, 8, 3, -7, -7],                            
        // well_depth = [5, 5, 0, 5, 5, 14],                            
        well_depth = [0, 0, 0, 0, 8, 8.1],                            
        roll_angles = [10, 0, 0, -8, -22, -42],
        pitch_angles = [
                        // [0, 0, 0, 0, 0, 0],              
                        [-22, -22, -22, -42, -22, -22],     // bottom row
                        [  0,   0,   0,   0,   0,   0],     // middle row
                        [ 10,  20,  10,  10,  10,  10]      // top row
                        // [0, 0, 0, 0, 0, 0],                 
                       ], //[for (i = [0: 2]) [for (j = [0:5]) 0]],      
        yaw_angles = [0, 0, 0, 0, -5, -5],                         
        column_padding = [5, 0, -1, 0, 0],    // distance between each column (can be negative)
        row_padding = [                         // individual padding for each row in each column (can be negative)
                        [5, 0, 0, -2, 0, 0],         // between bottom and middle row in column
                        [0, 0, 0, 0, 0, 0]          // between middle and top row in column
                      ],
        last_col_key_count = 2,
        spacing_x = 18,
        spacing_y = 17,
        key_module_height = 5.2,
        plate2cap_dist = 7.3,
        show_keycap = false, // used to visualise keycap for showing if there are any overlaps
    ){

    // - vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
    // Helper function to find next initial translate of column
    function next_col_x_translate(cur_col_index, col_index, initial_x_translate) =  
        cur_col_index == col_index 
            ? initial_x_translate //- vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
            : cur_col_index == 0 
                ?  next_col_x_translate( // first column -- same as posetive diff
                            cur_col_index + 1, 
                            col_index, 
                            initial_x_translate + vec_rotated_xyz(spacing_x, 0, key_module_height, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
                            - vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
                            )
                : roll_angles[cur_col_index - 1] - roll_angles[cur_col_index] >= 0
                    ? next_col_x_translate( // top aligned
                            cur_col_index + 1, 
                            col_index, 
                            initial_x_translate + vec_rotated_xyz(spacing_x, 0, key_module_height, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
                            - vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
                            )
                    : next_col_x_translate( // bottom aligned
                            cur_col_index + 1, 
                            col_index, 
                            initial_x_translate + vec_rotated_xyz(spacing_x, 0, 0, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
                            - vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
                            );

    // check if two line segments in xy (2D) plane intersect
        // a and b are one line segment
        // c and d are the other line segment
            // modified from https://openscadsnippetpad.blogspot.com/2017/06/intersection-of-lines.html
    // NOT NEEDED FOR NOW
    function  lines_intersect(a, b, c, d)=
        let(
                da = [(a.x-b.x),(a.y-b.y)], 
                db = [(c.x-d.x),(c.y-d.y)],
                the = da.x*db.y - da.y*db.x                 )
        (the == 0)
            ? false
            : true;


    // get angle of line sesgment from A to B compared to the x-axis
    function line_angle(A, B) = 
        atan2(B.y - A.y, B.x - A.x);
        

    // returns point with given y-value along line
    function point_on_line(A, B, y) = 
        let(
            m = (B.y - A.y)/(B.x - A.x),
            x = (y - A.y)/m + A.x
        )
        [x, y];



    // returns true if two line segments has any overlaping parts in y-axis
        // false otherwise
    function y_range_overlap(prev_A, prev_B, cur_A, cur_B) = 
        let(
            prev_min = min(prev_A.y, prev_B.y),
            prev_max = max(prev_A.y, prev_B.y),
            cur_min = min(cur_A.y, cur_B.y),
            cur_max = max(cur_A.y, cur_B.y)
        )
        prev_min <= cur_max && cur_min <= prev_max;

    function min_x_translate(prev_A, prev_B, cur_A, cur_B) = 
        y_range_overlap(prev_A, prev_B, cur_A, cur_B)
            ? point_on_line(cur_A, cur_B, min(prev_A.y, prev_B.y))[0]
            : 0; // no overlap so no translation needed correct this line combo




    function next_col_x_translate_new(cur_col_index, col_index, top_top, top_bottom, middle_top, middle_bottom, bottom_top, bottom_bottom) = 
        let(
            // following 3 variables are just used to compute the current points below them
            initial_translate = [
                                    0, 
                                    stagger[cur_col_index], 
                                    well_depth[cur_col_index]
                                ], 
            top_row_translate = next_key_translate(2, [for (j = [0:2]) pitch_angles[j][cur_col_index]], initial_translate, roll_angles[cur_col_index],
                                yaw_angles[cur_col_index], plate2cap_dist, [row_padding[0][cur_col_index], row_padding[1][cur_col_index]]),


            middle_row_translate = next_key_translate(1, [for (j = [0:2]) pitch_angles[j][cur_col_index]], initial_translate, roll_angles[cur_col_index],
                                yaw_angles[cur_col_index], plate2cap_dist, [row_padding[0][cur_col_index], row_padding[1][cur_col_index]]),

            // positions used to compute line segments (points along right side of keycaps for the current column)
            cur_top_top = top_row_translate + vec_rotated_xyz(spacing_x, spacing_y, key_module_height+plate2cap_dist, pitch_angles[2][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index]),
            cur_top_bottom = top_row_translate + vec_rotated_xyz(spacing_x, 0, key_module_height+plate2cap_dist, pitch_angles[2][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index]),
            cur_middle_top = middle_row_translate + vec_rotated_xyz(spacing_x, spacing_y, key_module_height+plate2cap_dist, pitch_angles[1][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index]),
            cur_middle_bottom = middle_row_translate + vec_rotated_xyz(spacing_x, 0, key_module_height+plate2cap_dist, pitch_angles[1][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index]),
            cur_bottom_top = initial_translate + vec_rotated_xyz(spacing_x, spacing_y, key_module_height+plate2cap_dist, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index]),
            cur_bottom_bottom = initial_translate + vec_rotated_xyz(spacing_x, 0, key_module_height+plate2cap_dist, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index]),


            // array to store tranlsates for comparisons
            translates = [10, 15, 3, 7, 50, 9, 1, 2]
        ) 
            cur_col_index == 0
                ? col_index == 0 ? 0
                    : next_col_x_translate_new(1, col_index, top_top, top_bottom, middle_top, middle_bottom, bottom_top, bottom_bottom)
                : // 0 not cur index find max translate from the min translates
            
            echo("MAX", max(translates))
            
        

            cur_bottom_top;

    // echo("Line angle", line_angle([0, 0], [-5, -0.00001]));
    //
    // echo("Point on line", point_on_line([0, 0], [-5, 13], -2));





    // function next_col_x_translate_new(cur_col_index, col_index, initial_x_translate) =
    //     let ( init_point = [0, 0, 0])
    //         next_col_x_translate_helper(cur_col_index, col_index, initial_x_translate, init_point, init_point, init_point, init_point, init_point, init_point);




// current_translate = next_key_translate(j, col_pitches, initial_translate, roll_angles[i], yaw_angles[i], plate2cap_dist, [row_padding[0][i], row_padding[1][i]]),
                
// function vec_rotated_xyz(x, y, z, rotation_x, rotation_y, rotation_z) =




    // translate([-0.05, -0.05, -0.05])
    translate(next_col_x_translate_new(0, 1, 0))
        // cube([0.1, 0.1, 0.1]);
        color("red")
        cube([1, 1, 1]);


    echo("Next col translate return vec", next_col_x_translate_new(0, 1, 0));

        // cur_col_index == col_index
        //     ? // return the x_translate value 
        //     : // compute min_translate for top and bottom line segments
        //         // select the biggest of the two as the translate for this column. 
        //             // compute the needed x_translate for the point bottom
              





                    // initial location would be prev tranlate and the corresponding pos in cube to find the line segemnt




    // computes the col padding that is user specified by the parameter to the module
    function compute_col_padding (cur_col_index, col_index, cur_col_padding) = 
        cur_col_index == col_index 
            ? cur_col_padding
            : compute_col_padding(cur_col_index + 1, col_index, cur_col_padding + column_padding[cur_col_index]);


    // echo()
    // echo(vec_rotated_xyz(spacing_x, 0, key_module_height, pitch_angles[0][0], roll_angles[0], yaw_angles[0])[0])
    // echo("next_col_translate", next_col_x_translate(0, 2, 0));
    prev_x_max = 0;


    // echo("compute_col_padding", compute_col_padding(0, 1, 0));
    
    // color("indigo")
    // translate([next_col_x_translate(0, 5, 0) + vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][5], roll_angles[5], yaw_angles[5])[0], -200, -200])
    //     cube([0.00001, 400, 400]);


    // WORK IN PROGRESS -- continue later does not work atm
    function aligned_translate(prev, curr, i) = 
        let(test = vec_rotated_xyz_generic(0, abs(prev[1] - curr[1]), 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i]))
        curr[1] - prev[1] > 0 
            ? prev + (abs(prev[1] - curr[1])/test[1]) * test // prev translate
            : curr + (abs(prev[1] - curr[1])/test[1]) * test; // curr translate





    function aligned_translate_bottom(z, initial_translate, prev_initial_translate, i, for_prev) = 
    // function aligned_translate_update(z, prev_initial_translate, initial_translate, i, for_prev) = 
        let(
            prev = prev_initial_translate + vec_rotated_xyz(spacing_x, 0, z, pitch_angles[0][i-1], roll_angles[i-1], yaw_angles[i-1]),
            curr = initial_translate + vec_rotated_xyz(0, 0, z, pitch_angles[0][i], roll_angles[i], yaw_angles[i]),
            edge_translate = curr[1] - prev[1] > 0 
                                ? for_prev ? vec_rotated_xyz_generic(0, abs(prev[1] - curr[1]), 0, pitch_angles[0][i-1], roll_angles[i-1], yaw_angles[i-1]) : [0, 0, 0] // previous col
                                : !for_prev ? vec_rotated_xyz_generic(0, abs(prev[1] - curr[1]), 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i]) : [0, 0, 0],      // current col
            edge_translate_scaled = edge_translate[1] == 0 ? edge_translate : (abs(prev[1] - curr[1])/edge_translate[1]) * edge_translate 
        )
        for_prev 
            ? prev + edge_translate_scaled 
            : curr + edge_translate_scaled;


    module column_gap_filler(i, j, initial_translate, prev_initial_translate) {
        // let (
        //         prev = prev_initial_translate + vec_rotated_xyz(spacing_x, 0, 0, pitch_angles[0][i-1], roll_angles[i-1], yaw_angles[i-1]),
        //         curr = initial_translate + vec_rotated_xyz(0, 0, 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i])
        // ){


            if (i != 0) {
                if (j == 0) {
                    // bottom row -- no need to account for row filler

                    // echo("prev", prev_initial_translate);

                    // echo("Top left back", aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i, true));
                    translate(aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i, true))
                        cube([1, 1, 1]);

                    // echo("Top right back", aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i, false));
                    translate(aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i, false))
                        cube([1, 1, 1]);

                    // echo("Bottom left back", aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, true));
                    translate(aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, true))
                        cube([1, 1, 1]);


                    // echo("Bottom right back", aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, false));
                    translate(aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, false))
                        cube([1, 1, 1]);


                    translate([-0.5, 0, 0])
                        translate(initial_translate + vec_rotated_xyz(0, spacing_y, 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i]))
                        cube([1, 1, 1]);

                    // translate(prev_initial_translate + vec_rotated_xyz(spacing_x, 0, 0, pitch_angles[0][i-1], roll_angles[i-1], yaw_angles[i-1])
                    //     cube([1, 1, 1]);

                    // if (
                    //      // bottom right back x-value > bottom right back x-value
                    //      aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, false)[0] > 
                    //      aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, true)[0]
                    //      &&
                    //      // top right back x-value > top left back x-value
                    //      aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i, true)[0] > 
                    //      aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i, false)[0]
                    //      &&
                    //      // bottom rigth front x-value > bottom left front x-value
                    //      (initial_translate + vec_rotated_xyz(0, spacing_y, 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i]))[0] > 
                    //      (prev_initial_translate + vec_rotated_xyz(spacing_x, spacing_y, 0, pitch_angles[0][i-1], roll_angles[i-1], yaw_angles[i-1]))[0]
                    //      &&
                    //      // top right front x-value > top left front x-value
                    //      (initial_translate + vec_rotated_xyz(0, spacing_y, key_module_height, pitch_angles[0][i], roll_angles[i], yaw_angles[i]))[0] > 
                    //      (prev_initial_translate + vec_rotated_xyz(spacing_x, spacing_y, key_module_height, pitch_angles[0][i-1], roll_angles[i-1], yaw_angles[i-1]))[0]
                    // ){ 
                    polyhedron(
                            points = [
                            // naming description assumes keyboard placed flat on a desk in normal user orientation
                            // top is the side facing up along they key caps (towards ceiling)
                            // bottom is the side facing down along the key caps (towards floor)
                            // --
                            // right is the side facing right 
                            // left is the side facing left 
                            // --
                            // back is towards the user using the keyboard (against their belly)
                            // front is side facing away from the user (towards monitor/wall)

                            // rear points
                            aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, false),                 // bottom right back
                            aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, true),                  // bottom left back
                            aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i, false), // top right back
                            aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i, true),  // top left back

                            // front points
                            initial_translate + vec_rotated_xyz(0, spacing_y, 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i]),                                    // bottom right front
                            prev_initial_translate + vec_rotated_xyz(spacing_x, spacing_y, 0, pitch_angles[0][i-1], roll_angles[i-1], yaw_angles[i-1]),                 // bottom left front
                            initial_translate + vec_rotated_xyz(0, spacing_y, key_module_height, pitch_angles[0][i], roll_angles[i], yaw_angles[i]),                    // top right front
                            prev_initial_translate + vec_rotated_xyz(spacing_x, spacing_y, key_module_height, pitch_angles[0][i-1], roll_angles[i-1], yaw_angles[i-1]), // top left front

                            ],

                            // remember right hand rule when assigning points to faces. 
                            // (thumb into the face and points must follow the curve of your fingers in space
                            // you go around in a circle for each face and you must follow the curve direction of your fingers
                            // when pointing them into the face to know the correct indecie to use for that corner)
                            // [See documentation on polyhedron on openscad wiki]
                            faces = 
                                [[0, 4, 5, 1], // bottom
                            [2, 3, 7, 6], // top
                            [0, 1, 3, 2], // back
                            [1, 5, 7, 3], // right
                            [4, 6, 7, 5], // front
                            [0, 2, 6, 4]] // left
                                );
                            // }
                } else {
                    // middle and top row -- account for row filler that combines to lower row

                }

        // }
            
        }// end of first if that checks if i != 0
    }



    col_count = last_col_key_count == 0 ? 4 : 5;
    for (i = [0:col_count]) {
        // columns

        // x shift must be dynamic based on prev yaw angles (cummulative)
        let (
                // initial_translate = [spacing_x * i, stagger[i], well_depth[i]], 
                initial_translate = [
                                        next_col_x_translate(0, i, 0) + (i>0 ? compute_col_padding(0, i, 0) : 0),
                                        stagger[i], 
                                        well_depth[i]
                                    ], 
                prev_initial_translate = i != 0 ?
                                    [
                                        next_col_x_translate(0, i-1, 0) + ((i-1)>0 ? compute_col_padding(0, i-1, 0) : 0),
                                        stagger[i-1], 
                                        well_depth[i-1]
                                    ] 
                                    : [0, 0, 0],
                col_pitches = [for (j = [0:2]) pitch_angles[j][i]]
            ){

            // echo("initial_translate", initial_translate);
            // if ( i > 0 ) {
            //     echo("Col:", i, " angle_diff ", roll_angles[i-1] - roll_angles[i]);
            // }
            

            // cube behind and on top of each column


                

            if (i == 9){
                    // translate(vec_rotated_xyz_generic(0, 50, 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i]))
                    //     cube([1, 1, 1]);
                    
                    // translate(initial_translate)
                    // translate(vec_rotated_xyz(0, 0, 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i]))
                    // translate(-vec_rotated_xyz_generic(25-spacing_x/2, 50, 25-key_module_height/2, pitch_angles[0][i], roll_angles[i], yaw_angles[i]))
                    // rotate([pitch_angles[0][i], roll_angles[i], yaw_angles[i]])
                    //         cube([50, 50, 50]);



                   // bottom_sub_box(pitch_angles[0][i], roll_angles[i], yaw_angles[i], initial_translate, spacing_x, key_module_height);


                    // top_sub_box(pitch_angles[2][i], roll_angles[i], yaw_angles[i], , spacing_x, key_module_height);


                let (
                        prev = prev_initial_translate + vec_rotated_xyz(spacing_x, 0, 0, pitch_angles[0][i-1], roll_angles[i-1], yaw_angles[i-1]),
                        curr = initial_translate + vec_rotated_xyz(0, 0, 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i])
                    ) {

                    // translate(vec_rotated_xyz(0, 0, 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i]))
                    // translate(initial_translate + vec_rotated_xyz(0, 0, 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i]))
                    if (curr[1] - prev[1] > 0) { // current col is higer up (y value) than the previous
                        // echo("veccy deccy succky bucky yeah", aligned_translate_update(key_module_height, prev_initial_translate, initial_translate, i, true));
                        // function aligned_translate_update(y, z, prev_initial_translate, initial_translate, i, for_prev) = 
                        // echo("text", aligned_translate_update(0, prev_initial_translate, initial_translate, i, true));
                        // translate(aligned_translate_update(0, prev_initial_translate, initial_translate, i, true))
                        // translate(aligned_translate(prev, curr, i-1))
                            // color("indigo")
                            // cube([1, 1, 1]);


                        
                        // echo("Currrrrrrrrr", curr);
                        // translate(curr)
                            // cube([1, 1, 1]);

            if (i != 0){
                column_gap_filler(i, 0, initial_translate, prev_initial_translate);
            }

                        // top cubes
                        // translate(curr)
                            // cube([1, 1, 1]);

                    }
                    else { // current col is lower down (y value) than the previous
                        // echo("prevv", prev);
                        // translate(prev)
                            // cube([1, 1, 1]);
                        if (i != 0){
                            column_gap_filler(i, 0, initial_translate, prev_initial_translate);
                        }
                        // echo("curr", aligned_translate(prev, curr, i));
                       // translate(aligned_translate(prev, curr, i))
                            // color("pink")
                            // cube([1, 1, 1]);
                                                


                    }

                }

            }


            



            for (j = [0:2]) {
                // individual keys in column
                let (
                        current_translate = next_key_translate(j, col_pitches, initial_translate, roll_angles[i], yaw_angles[i], plate2cap_dist, [row_padding[0][i], row_padding[1][i]]),
                        prev_translate = j != 0 ? 
                                        next_key_translate(j-1, col_pitches, initial_translate, roll_angles[i], yaw_angles[i], plate2cap_dist, [row_padding[0][i], row_padding[1][i]]) :
                                        [] // not used when j == 0
                ){

                    // if (i == 0 && j == 2){
                    //         top_sub_box(pitch_angles[2][i], roll_angles[i], yaw_angles[i], current_translate, spacing_y, key_module_height);
                    // }

                    if (!(i == 5 && j >= last_col_key_count)) { // to allow for 2 and 1 key last column
                        // colors used to show the column interference between keycaps different colors for clarity
                        let (colors = [ 
                                        [0.7+0.05*j, 0.4-0.1*j, 0.6, 0.5 - 0.1*j],
                                        [0.2+0.05*j, 0.5-0.1*j, 0.5, 0.5 - 0.1*j],
                                        [0.9+0.05*j, 0.2-0.1*j, 0.4, 0.5 - 0.1*j],
                                        [0.5+0.05*j, 0.8-0.1*j, 0.2, 0.5 - 0.1*j],
                                        [0.9+0.05*j, 0.5-0.1*j, 0.4, 0.5 - 0.1*j],
                                        [0.8+0.05*j, 0.2-0.1*j, 0.6, 0.5 - 0.1*j],
                                        [0.8+0.05*j, 0.9-0.1*j, 0.6, 0.5 - 0.1*j]
                                      ]
                            ){
                            if (i == 0 && j == 2){
                                echo("key translate");
                                echo("Initial_translate for center", initial_translate);
                                echo("current_translate", current_translate);


                                translate(current_translate)
                                    centered_key(
                                            rotation_x=pitch_angles[j][i], 
                                            rotation_y=roll_angles[i], 
                                            rotation_z=yaw_angles[i], 
                                            plate2cap_dist=plate2cap_dist,
                                            show_keycap=show_keycap, 
                                            keycap_color=colors[i]
                                            );


                                // place a cube on the top left corner of this key

                                // translate(current_translate + vec_rotated_xyz(spacing_x, spacing_y, key_module_height+plate2cap_dist, pitch_angles[j][i], roll_angles[i], yaw_angles[i]))
                                //     cube([1, 1, 1]);
                            } else {
                                translate(current_translate)
                                    centered_key(
                                            rotation_x=pitch_angles[j][i], 
                                            rotation_y=roll_angles[i], 
                                            rotation_z=yaw_angles[i], 
                                            plate2cap_dist=plate2cap_dist,
                                            show_keycap=show_keycap, 
                                            keycap_color=colors[i]
                                            );
                            }
                        }

                        if (j != 0) {
                            // draw the filler between key j and j-1 (current and previous)
                            color("aquamarine")
                                polyhedron(
                                        points = [
                                        // prev key points
                                        prev_translate + vec_rotated_xyz(0, spacing_y, 0, pitch_angles[j-1][i], roll_angles[i], yaw_angles[i]), // 0 -- top left back
                                        prev_translate + vec_rotated_xyz(spacing_x, spacing_y, 0, pitch_angles[j-1][i], roll_angles[i], yaw_angles[i]), // 1 -- top right back
                                        prev_translate + vec_rotated_xyz(spacing_x, spacing_y, key_module_height, pitch_angles[j-1][i], roll_angles[i], yaw_angles[i]), // 2 -- top right front
                                        prev_translate + vec_rotated_xyz(0, spacing_y, key_module_height, pitch_angles[j-1][i], roll_angles[i], yaw_angles[i]), // 3 -- top left front

                                        // current key points
                                        current_translate + vec_rotated_xyz(0, 0, 0, pitch_angles[j][i], roll_angles[i], yaw_angles[i]), // 4 -- bottom left back
                                        current_translate + vec_rotated_xyz(spacing_x, 0, 0, pitch_angles[j][i], roll_angles[i], yaw_angles[i]), // 5 -- bottom right back
                                        current_translate + vec_rotated_xyz(spacing_x, 0, key_module_height, pitch_angles[j][i], roll_angles[i], yaw_angles[i]), // 6 -- bottom right front 
                                        current_translate + vec_rotated_xyz(0, 0, key_module_height, pitch_angles[j][i], roll_angles[i], yaw_angles[i]), // 7 -- bottom left front 
                                        ],
                                        faces =  
                                        [[0,1,2,3],  // bottom -- top of prev key
                                        [4,5,1,0],  // back   -- back side (hotswap side)
                                        [7,6,5,4],  // top    -- bottom of current key
                                        [5,6,2,1],  // right  -- towards next column to right
                                        [6,7,3,2],  // front  -- front of case (where switchs are placed what you see top of desk)
                                        [7,4,0,3]]  // left   -- towards prev column to left

                                            // ######## DID NOT RENDER ########
                                            // for future reference -- this did not render but did preview correctly
                                            // the one above does preview and render correctly only ordering is different
                                            // so that matters. Not exacly sure why and how but consider this example if encountering 
                                            // issues like this in the future (I think its the order of the sides that must be connected
                                            // from previous to last don't think ordering of the corners in one face matters but could be wrong)
                                            //[
                                            //     [0, 1, 2, 3], // bottom -- top of prev key
                                            //     [4, 5, 6, 7], // top    -- bottom of current key
                                            //     [0, 1, 5, 4], // back   -- back side (hotswap side)
                                            //     [1, 2, 6, 5], // right  -- towards next column to right
                                            //     [2, 3, 7, 6], // front  -- front of case (where switchs are placed what you see top of desk)
                                            //     [3, 0, 4, 7]  // left   -- towards prev column to left
                                            // ]
                                );
                        }

                        column_gap_filler(i, j, initial_translate, prev_initial_translate);

                    }
                }
            }
        }
    }
}

main_keys(show_keycap=true);
