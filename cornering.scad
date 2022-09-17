$fn = 64;

// corner
color("red")
translate([4, 4, 0])
rotate([0, 0, 180])
intersection(){
    sphere(r = 4);
    cube([8, 8, 8]);
}


//edge
color("green")
translate([4, 0, 0])
intersection(){
    cube([12, 4, 4]);
    translate([0, 4, 0])
    rotate([0, 90, 0])
    cylinder(h=12, r=4);
}

translate([4, 4, 0])
rotate([0, 90, 180])
color("pink")
//translate([4, 0, 8])
intersection(){
    cube([12, 4, 4]);
    rotate([0, 90, 0])
    cylinder(h=12, r=4);
}