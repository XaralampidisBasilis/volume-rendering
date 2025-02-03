

// COMPUTE DEBUG 

// max intensity
vec4 debug_block_max_intensity = vec4(vec3(0.0), 1.0);
debug_block_max_intensity.xyz = vec3(block.max_intensity);

// occupied
vec4 debug_block_occupied = vec4(vec3(0.0), 1.0);
debug_block_occupied.xyz = vec3(block.occupied);

// coords
vec4 debug_block_coords = vec4(vec3(0.0), 1.0);
debug_block_coords.xyz = vec3(block.coords) / vec3(u_maxima_map.dimensions - 1);

// coords step
vec4 debug_block_coords_step = vec4(vec3(0.0), 1.0);
debug_block_coords_step.xyz = vec3(block.coords_step) * 0.5 + 0.5;

// min position
vec4 debug_block_min_position = vec4(vec3(0.0), 1.0);
debug_block_min_position.xyz = map(box.min_position, box.max_position, block.min_position);

// max position
vec4 debug_block_max_position = vec4(vec3(0.0), 1.0);
debug_block_max_position.xyz = map(box.min_position, box.max_position, block.max_position);

// PRINT DEBUG

switch (u_debugging.option - debug.slot_block)
{
    case 1: fragColor = debug_block_max_intensity;  break;
    case 2: fragColor = debug_block_occupied;       break;
    case 3: fragColor = debug_block_coords;         break;
    case 4: fragColor = debug_block_coords_step;    break;
    case 5: fragColor = debug_block_min_position;   break;
    case 6: fragColor = debug_block_max_position;   break;
}

  