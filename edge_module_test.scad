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

columns = 5; // zero indexed so 5 for 6 and 4 for 5
two_key_last_column = true; // might use for setting last row to be with or without key
stagger = [0, 2, 8, 2, -7, -7]; // max difference between neigbour columns is 9mm 



// side: 0 = top; 1 = right; 2 = bottom; 3 = left;
module edge(length, side){
    roate_deg = 90;
    translate_list = [0, 0, 0];
    
    translate(translate_list)
    rotate(roate_deg)
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


edge(18, 3);