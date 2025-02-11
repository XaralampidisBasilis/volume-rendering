

// COMPUTE DEBUG 

// max intensity
vec4 debug_block_max_intensity = to_color(block.max_intensity);

// occupied
vec4 debug_block_occupied = to_color(block.occupied);

// coords
vec4 debug_block_coords = to_color(vec3(block.coords) / vec3(u_maxima_map.dimensions - 1));

// coords step
vec4 debug_block_coords_step = to_color(vec3(block.coords_step) * 0.5 + 0.5);

// min position
vec4 debug_block_min_position = to_color(map(box.min_position, box.max_position, block.min_position));

// max position
vec4 debug_block_max_position = to_color(map(box.min_position, box.max_position, block.max_position));

// entry distance
vec4 debug_block_entry_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, block.entry_distance));

// exit distance
vec4 debug_block_exit_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, block.exit_distance));

// PRINT DEBUG

switch (u_debugging.option - debug_slot_block)
{
    case 1: fragColor = debug_block_max_intensity;  break;
    case 2: fragColor = debug_block_occupied;       break;
    case 3: fragColor = debug_block_coords;         break;
    case 4: fragColor = debug_block_coords_step;    break;
    case 5: fragColor = debug_block_min_position;   break;
    case 6: fragColor = debug_block_max_position;   break;
    case 7: fragColor = debug_block_entry_distance; break;
    case 8: fragColor = debug_block_exit_distance;  break;
}

  