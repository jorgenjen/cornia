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
    * spacing_y: keycahttps://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/p spacing y -- y-axis
   [int]
    * key_module_height: height of the key module -- z-axis [int]
    * plate2cap_dist: distance from the plate to top of keycap -- z-axis [int]

    * Default values are set for each param but each can be ovverriden
*/

module main_keys(stagger = [ 0, 2, 8, 3, -7, -7 ],
                 // well_depth = [5, 5, 0, 5, 5, 14],
                 well_depth = [ 12, 8, 0, 2, 8, 14.1 ], 
                 roll_angles = [ 14, 6, 0, -8, -22, -42 ],
                 pitch_angles =
                     [
                         // [ 0, 0, 0, 0, 0, 0 ],
                         [ -22, -22, -22, -42, -22, -22 ], // bottom row
                         [ 0, 0, 0, 0, 0, 0 ],             // middle row
                         [ 10, 20, 10, 10, 10, 10 ]        // top row
                         // [ 0, 0, 0, 0, 0, 0 ],
                     ], //[for (i = [0: 2]) [for (j = [0:5]) 0]],
                 yaw_angles = [ 0, 0, 0, 0, -5, -5 ],
                 // column_padding = [5, 0, -1, 0, 0],    // distance between each column (can be negative)
                 column_padding = [ 0, 0, 0, 0, 0 ], // distance between each column (can be negative)
                 row_padding =
                     [
                         // individual padding for each row in each column (can be negative)
                         [ 0, 0, 0, 0, 0, 0 ], // between bottom and middle row in column
                         [ 0, 0, 0, 0, 0, 0 ]  // between middle and top row in column
                     ],
                 last_col_key_count = 2,
                 spacing_x = 18,
                 spacing_y = 17,
                 key_module_height = 5.2,
                 plate2cap_dist = 7.3,
                 show_keycap = false, // used to visualise keycap for showing if there are any overlaps
)
{

    // - vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index], roll_angles[cur_col_index],
    // yaw_angles[cur_col_index])[0] Helper function to find next initial translate of column
    function next_col_x_translate(cur_col_index, col_index, initial_x_translate) =
        cur_col_index == col_index
            ? initial_x_translate //- vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index],
                                  // roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]
        : cur_col_index == 0 ? next_col_x_translate( // first column -- same as posetive diff
                                   cur_col_index + 1, col_index,
                                   initial_x_translate +
                                       vec_rotated_xyz(spacing_x, 0, key_module_height, pitch_angles[0][cur_col_index],
                                                       roll_angles[cur_col_index], yaw_angles[cur_col_index])[0] -
                                       vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index],
                                                       roll_angles[cur_col_index], yaw_angles[cur_col_index])[0])
        : roll_angles[cur_col_index - 1] - roll_angles[cur_col_index] >= 0
            ? next_col_x_translate( // top aligned
                  cur_col_index + 1, col_index,
                  initial_x_translate +
                      vec_rotated_xyz(spacing_x, 0, key_module_height, pitch_angles[0][cur_col_index],
                                      roll_angles[cur_col_index], yaw_angles[cur_col_index])[0] -
                      vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index],
                                      roll_angles[cur_col_index], yaw_angles[cur_col_index])[0])
            : next_col_x_translate( // bottom aligned
                  cur_col_index + 1, col_index,
                  initial_x_translate +
                      vec_rotated_xyz(spacing_x, 0, 0, pitch_angles[0][cur_col_index], roll_angles[cur_col_index],
                                      yaw_angles[cur_col_index])[0] -
                      vec_rotated_xyz(0, 0, key_module_height, pitch_angles[0][cur_col_index],
                                      roll_angles[cur_col_index], yaw_angles[cur_col_index])[0]);

    // check if two line segments in xy (2D) plane intersect
    // a and b are one line segment
    // c and d are the other line segment
    // modified from https://openscadsnippetpad.blogspot.com/2017/06/intersection-of-lines.html
    // NOT NEEDED FOR NOW
    function lines_intersect(a, b, c, d) = let(da = [ (a.x - b.x), (a.y - b.y) ], db = [ (c.x - d.x), (c.y - d.y) ],
                                               the = da.x * db.y - da.y * db.x)(the == 0)
                                               ? false
                                               : true;

    // NOT IN USE CURRENTLY
    // get angle of line sesgment from A to B compared to the x-axis
    function line_angle(A, B) = atan2(B.y - A.y, B.x - A.x);

    // returns point with given y-value along line
    function point_on_line(A, B, y) = let(m = (B.y - A.y) / (B.x - A.x), x = (y - A.y) / m + A.x)[x, y];
    function x_on_line_at_y(A, B, y) = A.y == B.y ? max(A.x, B.x) : A.x + (y - A.y) * (B.x - A.x) / (B.y - A.y);

    // returns true if two line segments has any overlaping parts in y-axis
    // false otherwise
    function y_range_overlap(prev_A, prev_B, cur_A, cur_B) = // verified to be correct by me the implementor :D
        let(prev_min = min(prev_A.y, prev_B.y), prev_max = max(prev_A.y, prev_B.y), cur_min = min(cur_A.y, cur_B.y),
            cur_max = max(cur_A.y, cur_B.y))
            // echo("prev_A", prev_A)
            prev_min <= cur_max &&
        cur_min <= prev_max;

    // minimum x translate needed so cur segment is not left of prev segment
    function min_x_translate(prev_A, prev_B, cur_A, cur_B) =
        y_range_overlap(prev_A, prev_B, cur_A, cur_B)
            ? let(overlap_min = max(min(prev_A.y, prev_B.y), min(cur_A.y, cur_B.y)),
                  overlap_max = min(max(prev_A.y, prev_B.y), max(cur_A.y, cur_B.y)),
                  min_translate_at_start = x_on_line_at_y(prev_A, prev_B, overlap_min) -
                                           x_on_line_at_y(cur_A, cur_B, overlap_min),
                  min_translate_at_end = x_on_line_at_y(prev_A, prev_B, overlap_max) -
                                         x_on_line_at_y(cur_A, cur_B, overlap_max))
                  max(min_translate_at_start, min_translate_at_end)
            : 0;

    function row_translate(row_index, col_index, initial_translate) =
        next_key_translate(row_index, [for (j = [0:2]) pitch_angles[j][col_index]], initial_translate,
                           roll_angles[col_index], yaw_angles[col_index], plate2cap_dist,
                           [ row_padding[0][col_index], row_padding[1][col_index] ]);

    function keycap_corner(row_index, col_index, x, y, z, x_translate) =
        let(initial_translate = [ 0, stagger[col_index], well_depth[col_index] ],
            row_pos = row_translate(row_index, col_index, initial_translate),
            x_offset = [ x_translate, 0, 0 ])
            row_pos + vec_rotated_xyz(x, y, z, pitch_angles[row_index][col_index], roll_angles[col_index],
                                      yaw_angles[col_index]) +
            x_offset;

    function keycap_top_corners(row_index, col_index, x_translate) =
        let(z = key_module_height + plate2cap_dist,
            back_left = keycap_corner(row_index, col_index, 0, 0, z, x_translate),
            back_right = keycap_corner(row_index, col_index, spacing_x, 0, z, x_translate),
            front_right = keycap_corner(row_index, col_index, spacing_x, spacing_y, z, x_translate),
            front_left = keycap_corner(row_index, col_index, 0, spacing_y, z, x_translate))
            [ back_left, back_right, front_right, front_left ];

    function keycap_top_edges(row_index, col_index, x_translate) =
        let(corners = keycap_top_corners(row_index, col_index, x_translate))
            [
                [ corners[0], corners[1] ],
                [ corners[1], corners[2] ],
                [ corners[2], corners[3] ],
                [ corners[3], corners[0] ]
            ];

    function column_keycap_top_edges(col_index, x_translate) =
        [for (row_index = [0:2], edge = keycap_top_edges(row_index, col_index, x_translate)) edge];

    function required_column_x_translate(prev_edges, cur_edges) =
        max(0, max([for (prev_edge = prev_edges, cur_edge = cur_edges)
                    min_x_translate(prev_edge[0], prev_edge[1], cur_edge[0], cur_edge[1])]));

    function next_col_x_translate_new(cur_col_index, col_index, prev_edges = [], accumulated_x_translate = 0) =
        cur_col_index == 0
            ? col_index == 0
                ? 0
                : next_col_x_translate_new(1, col_index, column_keycap_top_edges(0, 0), 0)
            : let(cur_x_translate =
                      required_column_x_translate(prev_edges, column_keycap_top_edges(cur_col_index, 0)),
                  cur_edges = column_keycap_top_edges(cur_col_index, cur_x_translate))
                  cur_col_index == col_index
                      ? cur_x_translate
                      : next_col_x_translate_new(cur_col_index + 1, col_index, cur_edges, cur_x_translate);

    // translate([0, 0, -1])
    translate([
        next_col_x_translate_new(0, 5),
        0, 0
    ]) color("orange") cube([ 1, 1, 10 ]);

    // ==========================================================
    //                          For testing
    // ==========================================================
    let(j = 2, i = 0,
        initial_translate =
            [ next_col_x_translate_new(0, i) + (i > 0 ? compute_col_padding(0, i, 0) : 0), stagger[i], well_depth[i] ],
        col_pitches = [for (j = [0:2]) pitch_angles[j][i]])
    {
        echo("i and j", i, j);
        translate(next_key_translate(j, col_pitches, initial_translate, roll_angles[i], yaw_angles[i], plate2cap_dist,
                                     [ row_padding[0][i], row_padding[1][i] ])) color("indigo") cube([ 1, 1, 1 ]);
    }

    echo("TRANSLATE TEST", [for (i = [0:5]) next_col_x_translate_new(0, i)]);

    // initial location would be prev tranlate and the corresponding pos in cube to find the line segemnt

    // computes the col padding that is user specified by the parameter to the module
    function compute_col_padding(cur_col_index, col_index, cur_col_padding) =
        cur_col_index == col_index
            ? cur_col_padding
            : compute_col_padding(cur_col_index + 1, col_index, cur_col_padding + column_padding[cur_col_index]);

    prev_x_max = 0;

    // WORK IN PROGRESS -- continue later does not work atm
    function aligned_translate(prev, curr, i) =
        let(test = vec_rotated_xyz_generic(0, abs(prev[1] - curr[1]), 0, pitch_angles[0][i], roll_angles[i],
                                           yaw_angles[i])) curr[1] - prev[1] > 0
            ? prev + (abs(prev[1] - curr[1]) / test[1]) * test  // prev translate
            : curr + (abs(prev[1] - curr[1]) / test[1]) * test; // curr translate

    function aligned_translate_bottom(z, initial_translate, prev_initial_translate, i, for_prev) =
        // function aligned_translate_update(z, prev_initial_translate, initial_translate, i, for_prev) =
        let(prev = prev_initial_translate +
                   vec_rotated_xyz(spacing_x, 0, z, pitch_angles[0][i - 1], roll_angles[i - 1], yaw_angles[i - 1]),
            curr = initial_translate + vec_rotated_xyz(0, 0, z, pitch_angles[0][i], roll_angles[i], yaw_angles[i]),
            edge_translate = curr[1] - prev[1] > 0
                                 ? for_prev
                                       ? vec_rotated_xyz_generic(0, abs(prev[1] - curr[1]), 0, pitch_angles[0][i - 1],
                                                                 roll_angles[i - 1], yaw_angles[i - 1])
                                       : [ 0, 0, 0 ] // previous col
                             : !for_prev ? vec_rotated_xyz_generic(0, abs(prev[1] - curr[1]), 0, pitch_angles[0][i],
                                                                   roll_angles[i], yaw_angles[i])
                                         : [ 0, 0, 0 ], // current col
            edge_translate_scaled =
                edge_translate[1] == 0 ? edge_translate : (abs(prev[1] - curr[1]) / edge_translate[1]) * edge_translate)
                for_prev
            ? prev + edge_translate_scaled
            : curr + edge_translate_scaled;

    module column_gap_filler(i, j, initial_translate, prev_initial_translate)
    {
        if (i != 0)
        {
            if (j == 0)
            {
                // bottom row -- no need to account for row filler
                translate(aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i,
                                                   true)) cube([ 1, 1, 1 ]);

                translate(aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i,
                                                   false)) cube([ 1, 1, 1 ]);

                translate(aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, true))
                    cube([ 1, 1, 1 ]);

                translate(aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, false))
                    cube([ 1, 1, 1 ]);

                translate([ -0.5, 0, 0 ])
                    translate(initial_translate + vec_rotated_xyz(0, spacing_y, 0, pitch_angles[0][i], roll_angles[i],
                                                                  yaw_angles[i])) cube([ 1, 1, 1 ]);
                polyhedron(
                    points =
                        [
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
                            aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, false), // bottom right back
                            aligned_translate_bottom(0, initial_translate, prev_initial_translate, i, true),  // bottom left back
                            aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i, false), // top right back
                            aligned_translate_bottom(key_module_height, initial_translate, prev_initial_translate, i, true), // top left back

                            // front points
                            initial_translate + vec_rotated_xyz(0, spacing_y, 0, pitch_angles[0][i], roll_angles[i],
                                                                yaw_angles[i]), // bottom right front
                            prev_initial_translate + vec_rotated_xyz(spacing_x, spacing_y, 0, pitch_angles[0][i - 1], roll_angles[i - 1], yaw_angles[i - 1]), // bottom left front
                            initial_translate + vec_rotated_xyz(0, spacing_y, key_module_height, pitch_angles[0][i],
                                                                roll_angles[i], yaw_angles[i]), // top right front
                            prev_initial_translate + vec_rotated_xyz(spacing_x, spacing_y, key_module_height,
                                                                     pitch_angles[0][i - 1], roll_angles[i - 1],
                                                                     yaw_angles[i - 1]), // top left front

                        ],

                    // remember right hand rule when assigning points to faces.
                    // (thumb into the face and points must follow the curve of your fingers in space
                    // you go around in a circle for each face and you must follow the curve direction of your fingers
                    // when pointing them into the face to know the correct indecie to use for that corner)
                    // [See documentation on polyhedron on openscad wiki]
                    faces = [
                        [ 0, 4, 5, 1 ], // bottom
                        [ 2, 3, 7, 6 ], // top
                        [ 0, 1, 3, 2 ], // back
                        [ 1, 5, 7, 3 ], // right
                        [ 4, 6, 7, 5 ], // front
                        [ 0, 2, 6, 4 ]  // left
                    ]);
            }
            else
            {
                // middle and top row -- account for row filler that combines to lower row
            }

            // }

        } // end of first if that checks if i != 0
    }

    col_count = last_col_key_count == 0 ? 4 : 5;
    for (i = [0:col_count])
    {
        // columns

        // x shift must be dynamic based on prev yaw angles (cummulative)
        let (
                // initial_translate = [spacing_x * i, stagger[i], well_depth[i]], 
                initial_translate = [
                                        next_col_x_translate_new(0, i) + (i>0 ? compute_col_padding(0, i, 0) : 0),
                                        stagger[i], 
                                        well_depth[i]
                                    ], 
                prev_initial_translate = i != 0 ?
                                    [
                                        next_col_x_translate_new(0, i-1) + ((i-1)>0 ? compute_col_padding(0, i-1, 0) : 0),
                                        stagger[i-1], 
                                        well_depth[i-1]
                                    ] 
                                    : [0, 0, 0],
                col_pitches = [for (j = [0:2]) pitch_angles[j][i]]
            )
        {
            if (i == 9)
            {
                let(prev = prev_initial_translate + vec_rotated_xyz(spacing_x, 0, 0, pitch_angles[0][i - 1],
                                                                    roll_angles[i - 1], yaw_angles[i - 1]),
                    curr =
                        initial_translate + vec_rotated_xyz(0, 0, 0, pitch_angles[0][i], roll_angles[i], yaw_angles[i]))
                {
                    if (curr[1] - prev[1] > 0)
                    { // current col is higer up (y value) than the previous
                        if (i != 0)
                        {
                            color("aquamarine", 0.5) column_gap_filler(i, 0, initial_translate, prev_initial_translate);
                        }
                    }
                    else
                    { // current col is lower down (y value) than the previous
                        if (i != 0)
                        {
                            color("pink", 0.5) column_gap_filler(i, 0, initial_translate, prev_initial_translate);
                        }
                    }
                }
            }

            for (j = [0:2])
            {
                // individual keys in column
                let(current_translate =
                        next_key_translate(j, col_pitches, initial_translate, roll_angles[i], yaw_angles[i],
                                           plate2cap_dist, [ row_padding[0][i], row_padding[1][i] ]),
                    prev_translate = j != 0 ? next_key_translate(j - 1, col_pitches, initial_translate, roll_angles[i],
                                                                 yaw_angles[i], plate2cap_dist,
                                                                 [ row_padding[0][i], row_padding[1][i] ])
                                            : [] // not used when j == 0
                )
                {
                    if (!(i == 5 && j >= last_col_key_count))
                    { // to allow for 2 and 1 key last column
                        // colors used to show the column interference between keycaps different colors for clarity
                        let(colors = [
                            [ 0.7 + 0.05 * j, 0.4 - 0.1 * j, 0.6, 0.5 - 0.1 * j ],
                            [ 0.2 + 0.05 * j, 0.5 - 0.1 * j, 0.5, 0.5 - 0.1 * j ],
                            [ 0.9 + 0.05 * j, 0.2 - 0.1 * j, 0.4, 0.5 - 0.1 * j ],
                            [ 0.5 + 0.05 * j, 0.8 - 0.1 * j, 0.2, 0.5 - 0.1 * j ],
                            [ 0.9 + 0.05 * j, 0.5 - 0.1 * j, 0.4, 0.5 - 0.1 * j ],
                            [ 0.8 + 0.05 * j, 0.2 - 0.1 * j, 0.6, 0.5 - 0.1 * j ],
                            [ 0.8 + 0.05 * j, 0.9 - 0.1 * j, 0.6, 0.5 - 0.1 * j ]
                        ])
                        {
                            if (i == 0 && j == 2)
                            {
                                echo("key translate");
                                echo("Initial_translate for center", initial_translate);
                                echo("current_translate", current_translate);

                                color("aquamarine", 0.5) translate(current_translate)
                                    centered_key(rotation_x = pitch_angles[j][i], rotation_y = roll_angles[i],
                                                 rotation_z = yaw_angles[i], plate2cap_dist = plate2cap_dist,
                                                 show_keycap = show_keycap, keycap_color = colors[i]);
                            }
                            else
                            {
                                color("aquamarine", 0.5) translate(current_translate)
                                    centered_key(rotation_x = pitch_angles[j][i], rotation_y = roll_angles[i],
                                                 rotation_z = yaw_angles[i], plate2cap_dist = plate2cap_dist,
                                                 show_keycap = show_keycap, keycap_color = colors[i]);
                            }
                        }

                        if (j != 0)
                        {
                            // draw the filler between key j and j-1 (current and previous)
                            color("aquamarine") polyhedron(
                                points =
                                    [
                                        // prev key points
                                        prev_translate + vec_rotated_xyz(0, spacing_y, 0, pitch_angles[j - 1][i],
                                                                         roll_angles[i],
                                                                         yaw_angles[i]), // 0 -- top left back
                                        prev_translate + vec_rotated_xyz(spacing_x, spacing_y, 0,
                                                                         pitch_angles[j - 1][i], roll_angles[i],
                                                                         yaw_angles[i]), // 1 -- top right back
                                        prev_translate + vec_rotated_xyz(spacing_x, spacing_y, key_module_height,
                                                                         pitch_angles[j - 1][i], roll_angles[i],
                                                                         yaw_angles[i]), // 2 -- top right front
                                        prev_translate + vec_rotated_xyz(0, spacing_y, key_module_height,
                                                                         pitch_angles[j - 1][i], roll_angles[i],
                                                                         yaw_angles[i]), // 3 -- top left front

                                        // current key points
                                        current_translate + vec_rotated_xyz(0, 0, 0, pitch_angles[j][i], roll_angles[i],
                                                                            yaw_angles[i]), // 4 -- bottom left back
                                        current_translate + vec_rotated_xyz(spacing_x, 0, 0, pitch_angles[j][i],
                                                                            roll_angles[i],
                                                                            yaw_angles[i]), // 5 -- bottom right back
                                        current_translate + vec_rotated_xyz(spacing_x, 0, key_module_height,
                                                                            pitch_angles[j][i], roll_angles[i],
                                                                            yaw_angles[i]), // 6 -- bottom right front
                                        current_translate + vec_rotated_xyz(0, 0, key_module_height, pitch_angles[j][i],
                                                                            roll_angles[i],
                                                                            yaw_angles[i]), // 7 -- bottom left front
                                    ],
                                faces = [
                                    [ 0, 1, 2, 3 ], // bottom -- top of prev key
                                    [ 4, 5, 1, 0 ], // back   -- back side (hotswap side)
                                    [ 7, 6, 5, 4 ], // top    -- bottom of current key
                                    [ 5, 6, 2, 1 ], // right  -- towards next column to right
                                    [ 6, 7, 3, 2 ], // front  -- front of case
                                    [ 7, 4, 0, 3 ]  // left   -- towards prev column to left
                                ]);
                        }

                        // TODO: Make this a part of the case rather than the key rows (make padding between and support
                        // down to plate with screw points for the thikest ones
                        // color("green", 0.5) column_gap_filler(i, j, initial_translate, prev_initial_translate);
                    }
                }
            }
        }
    }
}

main_keys(show_keycap = true);
