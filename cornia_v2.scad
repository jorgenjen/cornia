use <modules/key_unit.scad>


module main_keys(
        stagger = [0, 2, 8, 3, -7, -9], // Offset for each column (column stagger)
        splay_angles = [15, 22, 22],        // splay of final two/three columns (increasing order or same as prev)
        // splay_angles = [0, 0, 0],        // splay of final two/three columns (increasing order or same as prev)
        last_col_key_count = 2          // Number of keys for last column 0 no column 1/2/3 number of keys in column
    ){
    col_count = last_col_key_count == 0 ? 4 : 5;
    for (i = [0:col_count]) {
        translate([i*18, stagger[i] , 0])
        rotate([0, 0, (i-3 >= 0) ? -splay_angles[i-3] : 0])
        for (j = [0:2]) {
            translate([0, 17*j, 0]) 
            key(rotation_x = 0, rotation_z = 0);
        }
    }
}

main_keys();
