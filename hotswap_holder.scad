difference(){
    difference(){
        cube([10.85, 17.15, 3.15], center = false);
        translate([2, 3.8, 1.3]){
            linear_extrude(2.2, center = false){
                polygon(points=[[-0.05, 3], [2.15, 3], [2.15, -0.07], [6.9, -0.07], [6.9, 6.5], [4.7, 6.5],[4.7, 9.62], [-0.05, 9.62]]);
            }
        }
    }
    
    union(){
        translate([5.645, -0.1, 1.3])
            cube([1.86, 4, 3]);
        translate([3.445, 13.2, 1.3])
            cube([1.86, 4, 3]);
        
        translate([4.325, 11.25, -0.02])
            cylinder(h = 1.45, r = 1.95, $fn = 720);

        translate([6.525, 6.075, -0.02])
            cylinder(h = 1.45, r = 1.95, $fn = 720);
    }
}


