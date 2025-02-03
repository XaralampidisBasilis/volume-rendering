

// COMPUTE DEBUG 

// cheby distance
float debug_block_cheby_distance = float(block.cheby_distance) / float(u_distance_map.max_distance);
debug.block_cheby_distance = vec4(vec3(debug_block_cheby_distance), 1.0);

// occupied
debug.block_occupied = vec4(vec3(block.occupied), 1.0);

// coords
vec3 debug_block_coords = vec3(block.coords) / vec3(u_distance_map.dimensions - 1);
debug.block_coords = vec4(debug_block_coords, 1.0);

// coords step
vec3 debug_block_coords_step = (vec3(block.coords_step) / float(u_distance_map.max_distance)) * 0.5 + 0.5;
debug.block_coords_step  = vec4(debug_block_coords_step, 1.0);

// min position
vec3 debug_block_min_position = map(box.min_position, box.max_position, block.min_position);
debug.block_min_position = vec4(debug_block_min_position, 1.0);

// max position
vec3 debug_block_max_position = map(box.min_position, box.max_position, block.max_position);
debug.block_max_position = vec4(debug_block_max_position, 1.0);
    
           
// PRINT DEBUG

switch (u_debugging.option - debug.slot_block)
{
    case 1: fragColor = debug.block_cheby_distance; break;
    case 2: fragColor = debug.block_occupied;       break;
    case 3: fragColor = debug.block_coords;         break;
    case 4: fragColor = debug.block_coords_step;    break;
    case 5: fragColor = debug.block_min_position;   break;
    case 6: fragColor = debug.block_max_position;   break;
}

  