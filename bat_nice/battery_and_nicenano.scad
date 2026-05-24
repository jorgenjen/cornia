$fn = 36;
var = 3;
marg = 0.4; // spacing between each hole // think this might be better
nice_width = 18;
for(x = [0:nice_width-4:nice_width-4]){
    for(i = [0:2 + marg*2:(2+marg*2)*11]){
        translate([x + 3, 2 + i, 0])
        if (x == 0){
            linear_extrude(1)
            difference(){
                square([4, 2 + marg*2]);
                translate([2, 1 + marg, 0])
                    circle(1, $fn = 360); 
                translate([2.5, 1 + marg - 0.5, 0])
                square([1.5, 1], 0);
            }    
        } else {
            linear_extrude(1)
            difference(){
                square([4, 2 + marg*2]);
                translate([2, 1 + marg, 0])
                    circle(1, $fn = 360); 
                translate([0, 1 + marg - 0.5, 0])
                square([1.5, 1], 0);
            }    
            
        }
    }
}

battery_depth = 4.8;
wall_depth = 1;
nice_nano_depth = 3.3;


