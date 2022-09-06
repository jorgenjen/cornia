difference(){
    difference(){
        cube([10.85, 17.15, 5], center = false);
        translate([2, 3.8, 3]){
            linear_extrude(2.2, center = false){
                polygon(points=[[-0.03, 3.75], [2.17, 3.75], [2.17,     -0.03], [6.88, -0.03], [6.88, 5.75], [4.68, 5.75],[4.68, 9.58], [-0.03, 9.58]]);
            }
        }
    }
    union(){
        translate([5.685, -0.1, 3])
            cube([1.78, 4, 3]);
        translate([3.485, 13.2, 3])
            cube([1.78, 4, 3]);
    }
}
