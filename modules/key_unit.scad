$fn = 32; // set the resolution of the model (Low during developmet for fast renders)

// ===================================IMPORTANT_NOTE======================================
// use use instaead of include such that the demo does not show in the file you call it in
// =======================================================================================

// local variables only used for demo of module and functions in this file
local_rotation_x = -20;
local_rotation_z = -5;
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
        plate_slack = 0.05,             // Slack for the top square hole
        plate_depth_slack = 0.05,       // slack for thickness of ledge for top square
        width_padding = 0.25,           // Slack for widht of hotswap cutout
        height_padding = 0.25,          // Slack for height of hotswap cutout
        exit_padding = 0.5,             // Slack for width of rectangle for hotswap metallic contact pad
        ledge_width = 0.5,              // How big the ledge is around the cutout to hold the hotswap
        center_radius_slack = 0.35,     // Slack for center hole (big center pin of switch)
        sides_radius_slack = 0.25,      // Slack for side holes (smaller pins of switch)
        rotation_x = local_rotation_x,  // rotation of the xy plane so normal 2D rotation around z-axis (e.g, for splay of columns)
        rotation_z = local_rotation_z,  // rotation of the yz plane so normal 2D rotation around x-axis (e.g, for creating key wells)
        ){

    
    // move the key up along z-axis so the bottom of the key is at z == 0
    translate_by = rotation_x < 0 ? vec_rotated_xz(0, 17, 0, rotation_x, rotation_z, false): [0, 0, 0];

    translate([0, 0, -translate_by[2]])
    color("pink") // Set to one to make it look like one (uncomment for development of module)
    rotate([rotation_x, 0, rotation_z])
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

key();


// ====================================================================
//                          Helper functions 
// ====================================================================
    

// bottom_row means that the key has been translated up along z-axis to make the lowest point z=0
// so to get correct point location that translation must be accounted for hence the flag
function vec_rotated_xz(x, y, z, rotation_x, rotation_z, bottom_row) =
    // let translated_by = bottom_row ? vec_rotated_xz(0, 17, 0, rotation_x, rotation_z, false): [0, 0, 0];
    bottom_row ?
        [
            x*cos(rotation_z) - y*sin(rotation_z)*cos(rotation_x) + z*sin(rotation_z)*sin(rotation_x),
            x*sin(rotation_z) + y*cos(rotation_z)*cos(rotation_x) - z*cos(rotation_z)*sin(rotation_x),
            y*sin(rotation_x) + z*cos(rotation_x) - vec_rotated_xz(0, 17, 0, rotation_x, rotation_z, false)[2]
        ]:
        [
            x*cos(rotation_z) - y*sin(rotation_z)*cos(rotation_x) + z*sin(rotation_z)*sin(rotation_x),
            x*sin(rotation_z) + y*cos(rotation_z)*cos(rotation_x) - z*cos(rotation_z)*sin(rotation_x),
            y*sin(rotation_x) + z*cos(rotation_x)
        ];


// ====================================================================
//                      Demo of helper functions 
// ====================================================================


// top left back corner
color("Indigo")
translate(vec_rotated_xz(0, 17, 0, local_rotation_x, local_rotation_z, local_bottom_row))
    cube([1, 1, 1]);

// top right back corner
color("pink")
translate(vec_rotated_xz(18, 17, 0, local_rotation_x, local_rotation_z, local_bottom_row))
    cube([1, 1, 1]);

// bottom left back corner
color("teal")
translate(vec_rotated_xz(0, 0, 0, local_rotation_x, local_rotation_z, local_bottom_row))
    cube([1, 1, 1]);

// bottom right back corner
color("aquamarine")
translate(vec_rotated_xz(18, 0, 0, local_rotation_x, local_rotation_z, local_bottom_row))
    cube([1, 1, 1]);


// demo of front corners so facing user on switch side

// top left front corner
color("black")
translate(vec_rotated_xz(0, 17, 5.2, local_rotation_x, local_rotation_z, local_bottom_row))
      cube([1, 1, 1]);

// top right front corner
color("red")
translate(vec_rotated_xz(18, 17, 5.2, local_rotation_x, local_rotation_z, local_bottom_row))
    cube([1, 1, 1]);


// bottom left front corner
color("orange")
translate(vec_rotated_xz(0, 0, 5.2, local_rotation_x, local_rotation_z, local_bottom_row))
    cube([1, 1, 1]);

// bottom right front corner
color("yellow")
translate(vec_rotated_xz(18, 0, 5.2, local_rotation_x, local_rotation_z, local_bottom_row))
    cube([1, 1, 1]);


// plane to illustrate bottom to ensure no points are in the negatie z-axis visually
translate([0, 0, -0.01])
    cube([50, 50, 0.01]);
