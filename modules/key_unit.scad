$fn = 32; // set the resolution of the model (Low during developmet for fast renders)

// ===================================IMPORTANT_NOTE======================================
// use use instaead of include such that the demo does not show in the file you call it in
// =======================================================================================

// local variables only used for demo of module and functions in this file
local_rotation_x = 20;
local_rotation_y = 30;
local_rotation_z = 10;
local_bottom_row = true;

// Naming explained:
// Slack means how much larger a part of the model is in comparison to the schematics
// so if you leave all slack it will be same dimensions as the schematics but most printers
// will make the holes smaller than the moddel and hence won't work so slack varaibles must
// be tested to ensure good fit before full print
//
// for hotswap width is the short side 
// height is the long side with the connectors top and bottom
module key(
        plate_slack = 0.05,         // Slack for the top square hole
        plate_depth_slack = 0.05,   // slack for thickness of ledge for top square
        width_padding = 0.25,       // Slack for widht of hotswap cutout
        height_padding = 0.25,      // Slack for height of hotswap cutout
        exit_padding = 0.5,         // Slack for width of rectangle for hotswap metallic contact pad
        ledge_width = 0.5,          // How big the ledge is around the cutout to hold the hotswap
        center_radius_slack = 0.35, // Slack for center hole (big center pin of switch)
        sides_radius_slack = 0.25,  // Slack for side holes (smaller pins of switch)
        rotation_x = 0,             // rotation around the z-axis (e.g, for splay of columns)
        rotation_y = 0,             // rotation around the y-axis (e.g, for curving keys in or outwards for side sclupting)
        rotation_z = 0,             // rotation around the x-axis (e.g, for creating key wells)
        ){

    

    translate([0, 0, compute_translate_z_xyz(rotation_x, rotation_y, rotation_z)])
    // color("pink") // Set to one to make it look like one (uncomment for development of module)
    rotate([rotation_x, rotation_y, rotation_z])
    translate([0, 0, 0.9 + plate_depth_slack + 3]) // move the bottom to z == 0
    union(){
        // plate part
        color("red")
            linear_extrude(1.3 - plate_depth_slack)
            difference(){

                square([18, 17]);
                translate([2.1 + 1 - plate_slack/2, 1.6 - plate_slack/2])
                    square([13.8 + plate_slack, 13.8 + plate_slack]); // the x axis should mby be 13.6 not sure as the drawing is contradicting
            }

        color("blue")
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
                translate([0, 0, -3 - 0.9 - plate_depth_slack])
                    color("green")
                    linear_extrude(3)
                    square([18,17]);


                // translate is after roatate so we are moving the rightmost corner of the polygon from the origin (this is withough padding so padding is extra)
                translate([11.275 + 1, 0.175, -3.001 - 0.9 - plate_depth_slack])
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
            translate([9+1, 8.5, -3.001 - 0.9 - plate_depth_slack])
                cylinder(h = 10, r = 1.6 + center_radius_slack);
            color("indigo")
                translate([3.5+1, 8.5, -3.001 - 0.9 - plate_depth_slack])
                cylinder(h = 10, r = 0.9 + sides_radius_slack);

            // A cube to subtract to make the print quality better as the hole is too close to the hotswap part
            color("red")
                translate([3.6, 7, -3.001 - 0.9 - plate_depth_slack])
                cube([1.8, 1, 2.2]);



            translate([14.5+1, 8.5, -3.001 - 0.9 - plate_depth_slack])
                cylinder(h = 10, r = 0.9 + sides_radius_slack);
        }
    }

}



// centered key jus calls key() and removes 1mm extra to the left and adds it to the right and 
// then translates it back to the origin. hence the key is centered and the side lip is unifor on the parralell sides 
    // needed as when using rotation around x or y as it does not mesh well. Only works flat keyboard top surface
module centered_key(
        plate_slack = 0.05,         // Slack for the top square hole
        plate_depth_slack = 0.05,   // slack for thickness of ledge for top square
        width_padding = 0.25,       // Slack for widht of hotswap cutout
        height_padding = 0.25,      // Slack for height of hotswap cutout
        exit_padding = 0.5,         // Slack for width of rectangle for hotswap metallic contact pad
        ledge_width = 0.5,          // How big the ledge is around the cutout to hold the hotswap
        center_radius_slack = 0.35, // Slack for center hole (big center pin of switch)
        sides_radius_slack = 0.25,  // Slack for side holes (smaller pins of switch)
        rotation_x = 0,             // rotation around the z-axis (e.g, for splay of columns)                              / rotation of the xy plane so normal 2D rotation around z-axis (e.g, for splay of columns)
        rotation_y = 0,             // rotation around the y-axis (e.g, for curving keys in or outwards for side sclupting)
        rotation_z = 0,             // rotation around the x-axis (e.g, for creating key wells)
        ){


    translate([0, 0, compute_translate_z_xyz(rotation_x, rotation_y, rotation_z)])
    rotate([rotation_x, rotation_y, rotation_z])
    // color("orange")
    translate([-1, 0, 0])
        union(){
            difference(){
                key(
                    plate_slack,
                    plate_depth_slack, 
                    width_padding, 
                    height_padding, 
                    exit_padding, 
                    ledge_width, 
                    center_radius_slack, 
                    sides_radius_slack, 
                    0,
                    0
                );

                translate([-0.1, -0.1, -0.1])
                    cube([1.1, 20, 8.2]);
            }
            translate([18, 0, 0])
                cube([1, 17, 5.2]);
        }
}


// ====================================================================
//                          Helper functions 
// ====================================================================

// compute the needed z-axis translation to move the lowest connected part of the key 
// to 5.2 which is thickness of the key. The connected part is based on the rotation to decide top and bottom
// and side rotation is used to find the lowest of the corners in front or back depending on connected side
// then that value to get that corner to 5.2mm is computed
    // top row keys has the bottom corners connected
    // bottom row keys has the top corners connected
    // middle key is assumed to have rotation around x == 0 (does not nessesarily have to be the case)
function compute_translate_z_xyz(rotation_x, rotation_y, rotation_z) = 
    rotation_x < 0 ? 
        // bottom row key
        rotation_y < 0 ?
            5.2 - z_vec_rotated_xyz(0, 17, 5.2, rotation_x, rotation_y) : // left is lowest 
            5.2 - z_vec_rotated_xyz(18, 17, 5.2, rotation_x, rotation_y)  // right is lowest
    :
    rotation_x > 0 ? 
        // top row key
        rotation_y < 0 ?
            5.2 - z_vec_rotated_xyz(0, 0, 5.2, rotation_x, rotation_y) : // left is lowest 
            5.2 - z_vec_rotated_xyz(18, 0, 5.2, rotation_x, rotation_y)  // right is lowest
    :
    0; // middle key
   


// computes the z-position of point xyz after rotation along the three axis
function z_vec_rotated_xyz(x, y, z, rotation_x, rotation_y) = 
        -x*sin(rotation_y) + y*cos(rotation_y)*sin(rotation_x) + z*cos(rotation_y)*cos(rotation_x);


// computes the position of point xyz after rotation along the three axis
function vec_rotated_xyz(x, y, z, rotation_x, rotation_y, rotation_z) =
    [
        x*cos(rotation_z)*cos(rotation_y) +
        y*(cos(rotation_z)*sin(rotation_y)*sin(rotation_x) - sin(rotation_z)*cos(rotation_x)) + 
        z*(cos(rotation_z)*sin(rotation_y)*cos(rotation_x) + sin(rotation_z)*sin(rotation_x))
        ,
        x*sin(rotation_z)*cos(rotation_y) +
        y*(sin(rotation_z)*sin(rotation_y)*sin(rotation_x) + cos(rotation_z)*cos(rotation_x)) +
        z*(sin(rotation_z)*sin(rotation_y)*cos(rotation_x) - cos(rotation_z)*sin(rotation_x))
        ,
        -x*sin(rotation_y) + y*cos(rotation_y)*sin(rotation_x) + z*cos(rotation_y)*cos(rotation_x)
        + compute_translate_z_xyz(rotation_x, rotation_y, rotation_z)
    ];



// computes next key translate based on previous translates recursively
//     used to build up the columns from bottom up
function next_key_translate(col_pos, col_pitches, initial_translate, roll, yaw, plate2switch_height) =
    col_pos == 0 ?
        initial_translate
    :
    next_key_translate(col_pos - 1, col_pitches, initial_translate, roll, yaw, plate2switch_height) + 
    vec_rotated_xyz(0, 17, 5.2 + plate2switch_height, col_pitches[col_pos - 1], roll, yaw) -
    vec_rotated_xyz(0, 0, 5.2 + plate2switch_height, col_pitches[col_pos], roll, yaw);
        
    


// ====================================================================
//                            Demo of keys
// ====================================================================

centered_key(rotation_x=local_rotation_x, rotation_y=local_rotation_y, rotation_z=local_rotation_z);

translate([0, 28.7, 0])
key(rotation_x=local_rotation_x, rotation_y=local_rotation_y, rotation_z=local_rotation_z);



// ====================================================================
//              Demo of corner computation functions 
// ====================================================================

// uses the functions to place the small cubes onto the corners
// illustrates correct corner computations

// top left back corner
color("Indigo")
translate(vec_rotated_xyz(0, 17, 0, local_rotation_x, local_rotation_y, local_rotation_z))
    cube([1, 1, 1]);

// top right back corner
color("pink")
translate(vec_rotated_xyz(18, 17, 0, local_rotation_x, local_rotation_y, local_rotation_z))
    cube([1, 1, 1]);

// bottom left back corner
color("teal")
translate(vec_rotated_xyz(0, 0, 0, local_rotation_x, local_rotation_y, local_rotation_z))
    cube([1, 1, 1]);

// bottom right back corner
color("aquamarine")
translate(vec_rotated_xyz(18, 0, 0, local_rotation_x, local_rotation_y, local_rotation_z))
    cube([1, 1, 1]);


// demo of front corners so facing user on switch side

// top left front corner
color("black")
translate(vec_rotated_xyz(0, 17, 5.2, local_rotation_x, local_rotation_y, local_rotation_z))
      cube([1, 1, 1]);

// top right front corner
color("red")
translate(vec_rotated_xyz(18, 17, 5.2, local_rotation_x, local_rotation_y, local_rotation_z))
    cube([1, 1, 1]);


// bottom left front corner
color("green")
translate(vec_rotated_xyz(0, 0, 5.2, local_rotation_x, local_rotation_y, local_rotation_z))
    cube([1, 1, 1]);

// bottom right front corner
color("yellow")
translate(vec_rotated_xyz(18, 0, 5.2, local_rotation_x, local_rotation_y, local_rotation_z))
    cube([1, 1, 1]);


// plane to illustrate bottom to ensure no points are in the negatie z-axis visually
color("lightgrey")
// translate([-5, -5, 5.2])
translate([0, 0, -0.01])
    cube([100, 50, 0.01]);


// ====================================================================
//                   Demo of alignemt along top of key caps 
// ====================================================================


// transparent cubes illustrates the space taken by the switch and keycap when placed in the socket
// in reality they are smaller in widht and height but follows the spacing of 18x17
plate2switch_height = 7.3;
pitch_back = -20;
pitch_middle = 10;
pitch_front = 55; 


roll = -40;
yaw = 2;

back_key_translate = [0, 0, 0];

translate([50, 0, 0])
union() {
    // back key
    translate(next_key_translate(0, [pitch_back, pitch_middle, pitch_front], back_key_translate, roll, yaw, plate2switch_height))
    union() {
        color([0.7, 0.1, 0.9, 0.5])
        translate(vec_rotated_xyz(0, 0, 5.2, pitch_back, roll, yaw))
        rotate([pitch_back, roll, yaw])
            cube([18, 17, plate2switch_height]);
        centered_key(rotation_x=pitch_back, rotation_y=roll, rotation_z=yaw);
    }

    // middle key
    translate(next_key_translate(1, [pitch_back, pitch_middle, pitch_front], back_key_translate, roll, yaw, plate2switch_height))
        union() {
            color([0.9, 0.9, 0.9, 0.5])
            translate(vec_rotated_xyz(0, 0, 5.2, pitch_middle, roll, yaw))
            rotate([pitch_middle, roll, yaw])
                cube([18, 17, plate2switch_height]);
            centered_key(rotation_x=pitch_middle, rotation_y=roll, rotation_z=yaw);
        }


    // front key
    translate(next_key_translate(2, [pitch_back, pitch_middle, pitch_front], back_key_translate, roll, yaw, plate2switch_height))
        union() {
            color([0.2, 0.7, 0.4, 0.5])
            translate(vec_rotated_xyz(0, 0, 5.2, pitch_front, roll, yaw))
            rotate([pitch_front, roll, yaw])
                cube([18, 17, plate2switch_height]);
            centered_key(rotation_x=pitch_front, rotation_y=roll, rotation_z=yaw);
        }

}






// ==========================UNUSED FUNCTIONS==========================
//                      added for future reference 
// ====================================================================

// min height functions computed based on triangle does ensure non-interference of keycaps
// but does not align according to the z-axis which is not what I desired for this project
// so they are not used but could be usefull if you want a smaller board that does not align
// the keycaps and have overlap that does not interfere. Seems like from testing that it's not 
// perfect for some angles and coputes too large gap
function base_angle(pitch_angle) =
    180 - 90 - abs(pitch_angle);

function min_padding(pitch_angle_1, pitch_angle_2, plate_2_keycap_height) = 
    let (top_angle = 180 - base_angle(pitch_angle_1) - base_angle(pitch_angle_2))
    sin(top_angle) * plate_2_keycap_height / sin(base_angle(pitch_angle_2));
