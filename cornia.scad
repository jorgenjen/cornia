use <modules/key_unit.scad>

/* Creates the key grid/well the keys used by all fingers besides the thumb 
    * stagger: stagger of the key columns -- offset along y-axis where each column starts at the bottom [list]
    * well_depth: depth offset of each column -- used to create key well (offset along z-axis) [list]
    * roll_angles: roll angle of each column -- rotation around the y-axis [list]
    * pitch_angles: pitch angle of each key -- rotation around the x-axis [2D list]
    * yaw_angles: yaw angle of each column -- rotation around the z-axis [list]
    * last_col_key_count: number of keys in the last column -- 0 no column 1/2/3 number of keys in column [int]

    * Default values are set for each param but each can be ovverriden
*/
module main_keys(
        stagger = [0, 2, 8, 3, -7, -9],                            
        well_depth = [5, 5, 0, 5, 5, 5],                            
        roll_angles = [10, 0, 0, 0, -22, -22],
        pitch_angles = [
                        // [0, 0, 0, 0, 0, 0],              
                        [-22, -22, -22, -22, -22, -22],     // bottom row
                        [0, 0, 0, 0, 0, 0],                 // middle row
                        [10, 10, 10, 10, 10, 10]            // top row
                        // [0, 0, 0, 0, 0, 0],                 
                       ], //[for (i = [0: 2]) [for (j = [0:5]) 0]],      
        yaw_angles = [0, 0, 0, 0, -5, -10],                         
        last_col_key_count = 2,
        spacing_x = 18,
        spacing_y = 17,
        plate2switch_height = 7.3,
    ){
    prev_x_max = 0;

    col_count = last_col_key_count == 0 ? 4 : 5;
    for (i = [0:col_count]) {
        // columns

        // x here must be dynamic based on prev yaw angles (cummulative)
        let (initial_translate = [spacing_x * i, stagger[i], well_depth[i]], col_pitches=[for (j = [0:2]) pitch_angles[j][i]]) {
            for (j = [0:2]) {
                // individual keys in column
                translate(next_key_translate(j, col_pitches, initial_translate, roll_angles[i], yaw_angles[i], plate2switch_height))
                    centered_key(rotation_x=pitch_angles[j][i], rotation_y=roll_angles[i], rotation_z=yaw_angles[i]);
            }
        }
    }
}

main_keys();
