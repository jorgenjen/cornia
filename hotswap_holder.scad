difference(){
    difference(){
        cube([10.85, 17.15, 5], center = false);
        translate([2, 3.8, 3]){
            linear_extrude(2.2, center = false){
                polygon(points=[[0, 3.75], [2.2, 3.75], [2.2, 0], [6.85,0], [6.85, 5.75], [4.65, 5.75],[4.65, 9.55], [0, 9.55]]);
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



//polygon(points=[[0,0],[100,0],[130,50],[30,50]]);