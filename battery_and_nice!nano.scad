var = 3;
marg = 0.65;
nice_width = 18;
for(x = [0:nice_width-4:nice_width-4]){
    for(i = [0:2 + marg*2:(2+marg*2)*11]){
        translate([x, 1.5 + i, 0])
        linear_extrude(2)
        difference(){
            square([4, 2 + marg*2]);
            translate([2, 1 + marg, 0])
                circle(1, $fn = 360);            
        }    
    }
    translate([x, 0, 0])
        cube([4, 1.51, 2]);
    translate([x, 1.5 + (2+marg*2)*12])
        cube([4, 1.51, 2]);
}

//combining beam just for test print
translate([3.99, 0, 0])
    cube([10.02, 1, 2]);
translate([3.99, 2.01 + (2+marg*2)*12, 0])
    cube([10.02, 1, 2]);