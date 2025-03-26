
// COMPUTE DEBUG

// intersected
vec4 debug_block_intersected = to_color(block.intersected);

// terminated
vec4 debug_block_terminated = to_color(block.terminated);

// cheby distance
vec4 debug_block_cheby_distance = to_color(float(block.cheby_distance) / 128.0);

// coords
vec4 debug_block_coords = to_color(vec3(block.coords) * u_volume.inv_dimensions);

// coords step
vec4 debug_block_coords_step = to_color(vec3(block.coords_step) * 0.5 + 0.5); 

// entry distance
vec4 debug_block_entry_distance = to_color(map(0.0, box.max_span_distance, block.entry_distance)); 

// exit distance
vec4 debug_block_exit_distance = to_color(map(0.0, box.max_span_distance, block.exit_distance)); 

// span distance
vec4 debug_block_span_distance = to_color((block.exit_distance - block.entry_distance) / length(vec3(1.0))); 

// min position
vec4 debug_block_min_position = to_color(map(box.min_position, box.max_position, block.min_position)); 

// max position
vec4 debug_block_max_position = to_color(map(box.min_position, box.max_position, block.max_position)); 

// PRINT DEBUG

switch (u_debugging.option - debug_slot_block)
{ 
    case  1: fragColor = debug_block_intersected;    break;
    case  2: fragColor = debug_block_terminated;     break;
    case  3: fragColor = debug_block_cheby_distance; break;
    case  4: fragColor = debug_block_coords;         break;
    case  5: fragColor = debug_block_coords_step;    break;
    case  6: fragColor = debug_block_max_position;   break;
    case  7: fragColor = debug_block_min_position;   break;
    case  8: fragColor = debug_block_entry_distance; break;
    case  9: fragColor = debug_block_exit_distance;  break;
    case 10: fragColor = debug_block_span_distance;  break;
}

