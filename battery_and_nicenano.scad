$fn = 36;

var = 3;
marg = 0.4; // think this might be better
nice_width = 18;
for(x = [0:nice_width-4:nice_width-4]){
    for(i = [0:2 + marg*2:(2+marg*2)*11]){
        translate([x + 3, 2 + i, 0])
        linear_extrude(1)
        difference(){
            square([4, 2 + marg*2]);
            translate([2, 1 + marg, 0])
                circle(1, $fn = 360); 
        }    
    }
    //translate([x, 0, 0])
      //  cube([4, 1.51, 1]);
    //translate([x, 1.5 + (2+marg*2)*12])
      //  cube([4, 1.51, 1]);
}

//combining beam just for test print
//translate([3.99, 0, 0])
  //  cube([10.02, 1, 1]);
//translate([3.99, 2.01 + (2+marg*2)*12, 0])
  //  cube([10.02, 1, 1]);

//cube([18, 2, 1]);

//translate([0, (2 + marg * 2) * 12 + 2, 0])
//cube([18, 2, 1]);


battery_depth = 4.8;
wall_depth = 1;
nice_nano_depth = 3.3;


translate([0, 2, -1.5])
cube([3, (2 + marg * 2) * 12, 2.5 + nice_nano_depth]);

color("green")
translate([0, 2, 1 + nice_nano_depth])
cube([1, (2 + marg * 2) * 12, wall_depth]);

color("red")
translate([0, 2, 1 + nice_nano_depth + wall_depth])
cube([1.6, (2 + marg * 2) * 12, battery_depth]);


translate([nice_width + 3, 2, -1.5])
cube([3, (2 + marg * 2) * 12, 2.5 + nice_nano_depth]);


color("green")
translate([nice_width + 5, 2, 1 + nice_nano_depth])
cube([1, (2 + marg * 2) * 12, wall_depth]);


color("red")
translate([nice_width + 4.4, 2, 1 + nice_nano_depth + wall_depth])
cube([1.6, (2 + marg * 2) * 12, battery_depth]);


// roof
translate([0, 2, 1 + nice_nano_depth + + wall_depth + battery_depth])
cube([24, (2 + marg * 2) * 12, 1]);

//wall
difference(){
    translate([0, 2 + (2 + marg * 2) * 12, -1.5])
    cube([24, 1, 2.5 + nice_nano_depth + wall_depth + battery_depth + 1]);

    translate([9.2, 2 + (2 + marg * 2) * 12 + 1.1, 2.55])
    rotate([90, 0, 0])
    linear_extrude(1.2)
    hull() {
        translate([5.6,0,0]) 
            circle(1.5);
        circle(1.5);
    }
}

// usb c cut out



