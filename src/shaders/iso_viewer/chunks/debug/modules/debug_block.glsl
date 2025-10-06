

// COMPUTE DEBUG 

// skip distance
vec4 debug_block_skip_coords = to_color(vec3(block.skip_coords) / 31.0);

// occupied
vec4 debug_block_occupied = to_color(block.occupied);

// terminated
vec4 debug_block_terminated = to_color(block.terminated);

// coords
vec4 debug_block_coords = to_color(vec3(block.coords) / vec3(u_volume.blocked_dimensions - 1));

// exit_normal
vec4 debug_block_exit_normal = to_color(vec3(block.exit_normal));

// entry distance
vec4 debug_block_entry_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, block.entry_distance));

// exit distance
vec4 debug_block_exit_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, block.exit_distance));

// span distance
vec4 debug_block_span_distance = to_color(block.span_distance / length(block.max_position - block.min_position)); 

// min position
vec4 debug_block_min_position = to_color(map(box.min_position, box.max_position, block.min_position));

// max position
vec4 debug_block_max_position = to_color(map(box.min_position, box.max_position, block.max_position));

// PRINT DEBUG

switch (u_debug.option - 400)
{
    case  1: fragColor = debug_block_skip_coords;  break;
    case  2: fragColor = debug_block_occupied;       break;
    case  3: fragColor = debug_block_terminated;     break;
    case  4: fragColor = debug_block_coords;         break;
    case  5: fragColor = debug_block_exit_normal;    break;
    case  6: fragColor = debug_block_entry_distance; break;
    case  7: fragColor = debug_block_exit_distance;  break;
    case  8: fragColor = debug_block_span_distance;  break;
    case  9: fragColor = debug_block_min_position;   break;
    case 10: fragColor = debug_block_max_position;   break;
}

  