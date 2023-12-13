use <modules/key_unit.scad>

/* Creates the key grid/well the keys used by all fingers besides the thumb 
    * stagger: stagger of the key columns -- offset along y-axis where each column starts at the bottom [list]
    * well_depth: depth offset of each column -- used to create key well (offset along z-axis) [list]
    * roll_angles: roll angle of each column -- rotation around the y-axis [list]
    * pitch_angles: pitch angle of each key -- rotation around the x-axis [2D list]
    * yaw_angles: yaw angle of each column -- rotation around the z-axis [list]
    * last_col_key_count: number of keys in the last column -- 0 no column 1/2/3 number of keys in column [int]
    * spacing_x: keycap spacing x -- x-axis [int]
    * spacing_y: keycap spacing y -- y-axis [int]
    * key_module_height: height of the key module -- z-axis [int]
    * plate2cap_dist: distance from the plate to top of keycap -- z-axis [int]

    * Default values are set for each param but each can be ovverriden
*/


module main_keys(
        stagger = [0, 2, 8, 3, -7, -7],                            
        // well_depth = [5, 5, 0, 5, 5, 14],                            
        well_depth = [0, 0, 0, 0, 0, 8.1],                            
        roll_angles = [10, 0, 0, -8, -22, -42],
        pitch_angles = [
                        // [0, 0, 0, 0, 0, 0],              
                        [-22, -22, -22, -42, -22, -22],     // bottom row
                        [  0,   0,   0,   0,   0,   0],     // middle row
                        [ 10,  20,  10,  10,  10,  10]      // top row
                        // [0, 0, 0, 0, 0, 0],                 
                       ], //[for (i = [0: 2]) [for (j = [0:5]) 0]],      
        yaw_angles = [0, 0, 0, 0, -5, -5],                         
        column_padding = [5, 0, 0, 0, 2],    // distance between each column (can be negative)
        row_padding = [                         // individual padding for each row in each column (can be negative)
                        [0, 0, 0, 0, 0, 0],         // between bottom and middle row in column
                        [0, 0, 0, 0, 0, 0]          // between middle and top row in column
                      ],
        last_col_key_count = 2,
        spacing_x = 18,
        spacing_y = 17,
        key_module_height = 5.2,
        plate2cap_dist = 7.3,
    ){

    // - vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
    // Helper function to find next initial translate of column
    function next_col_x_translate(cur_col_index, col_index, initial_x_translate) =  
        cur_col_index == col_index 
            ? initial_x_translate - vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index], roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
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


    function compute_col_padding (cur_col_index, col_index, cur_col_padding) = 
        cur_col_index == col_index 
            ? cur_col_padding
            : compute_col_padding(cur_col_index + 1, col_index, cur_col_padding + column_padding[cur_col_index]);
            // : cur_col_index == 0
                // ? compute_col_padding(cur_col_index + 1, col_index, cur_col_padding + column_padding[cur_col_index])
                // : compute_col_padding(cur_col_index + 1, col_index, cur_col_padding);


    // echo()
    // echo(vec_rotated_xyz(spacing_x, 0, key_module_height, pitch_angles[0][0], roll_angles[0], yaw_angles[0])[0])
    echo("next_col_translate", next_col_x_translate(0, 2, 0));
    prev_x_max = 0;


    echo("compute_col_padding", compute_col_padding(0, 1, 0));
    
    // color("indigo")
    // translate([next_col_x_translate(0, 5, 0) + vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][5], roll_angles[5], yaw_angles[5])[0], -200, -200])
    //     cube([0.00001, 400, 400]);

    col_count = last_col_key_count == 0 ? 4 : 5;
    for (i = [0:col_count]) {
        // columns

        // x here must be dynamic based on prev yaw angles (cummulative)
        let (
                // initial_translate = [spacing_x * i, stagger[i], well_depth[i]], 
                initial_translate = [next_col_x_translate(0, i, 0) + (i>0 ? compute_col_padding(0, i, 0) : 0), stagger[i], well_depth[i]], 
                col_pitches = [for (j = [0:2]) pitch_angles[j][i]]
            ){

            // echo("initial_translate", initial_translate);
            // if ( i > 0 ) {
            //     echo("Col:", i, " angle_diff ", roll_angles[i-1] - roll_angles[i]);
            // }

            for (j = [0:2]) {
                // individual keys in column
                let (
                        current_translate = next_key_translate(j, col_pitches, initial_translate, roll_angles[i], yaw_angles[i], plate2cap_dist),
                        prev_translate = j != 0 ? 
                                        next_key_translate(j-1, col_pitches, initial_translate, roll_angles[i], yaw_angles[i], plate2cap_dist) :
                                        [] // not used when j == 0
                ){

                    if (!(i == 5 && j >= last_col_key_count)) { // to allow for 2 and 1 key last column
                        translate(current_translate)
                            centered_key(rotation_x=pitch_angles[j][i], rotation_y=roll_angles[i], rotation_z=yaw_angles[i]);

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

                    }
                }
            }
        }
    }
}

main_keys();
