width_padding = 0.05;
height_padding = 0.07;
radius_padding = 0.5;
exit_padding = 0.5;


difference(){
    difference(){
        cube([10.85, 17.15, 3.15], center = false);
        translate([2, 3.8, 1.3]){
            linear_extrude(2.2, center = false){
                polygon(points=[
                    [0 - width_padding, 3.75],
                    [2.2 - width_padding, 3.75], 
                    [2.2 - width_padding, 0 - height_padding],
                    [6.85 + width_padding,0 - height_padding],
                    [6.85 + width_padding, 5.75],
                    [4.65 + width_padding, 5.75],
                    [4.65 + width_padding, 9.55 + height_padding],
                    [0 - width_padding, 9.55 + height_padding]
                ]);
            }
        }
    }
    
    union(){
        translate([5.685 - exit_padding/2, -0.1, 1.3])
            cube([1.68 + exit_padding, 4, 3]);
        translate([3.485 - exit_padding/2, 13.2, 1.3])
            cube([1.68 + exit_padding, 4, 3]);
        
        translate([4.325, 11.25, -0.02])
            cylinder(h = 1.45, r = 1.45 + radius_padding, $fn = 360);

        translate([6.525, 6.075, -0.02])
            cylinder(h = 1.45, r = 1.45 + radius_padding, $fn = 360);
    }
}


