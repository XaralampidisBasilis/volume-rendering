
// COMPUTE DEBUG

// occupied
vec4 debug_voxel_occupied = to_color(voxel.occupied);

// intersected
vec4 debug_voxel_intersected = to_color(voxel.intersected);

// terminated
vec4 debug_voxel_terminated = to_color(voxel.terminated);

// coords
vec4 debug_voxel_coords = to_color(vec3(voxel.coords) * u_intensity_map.inv_dimensions);

// coords step
vec4 debug_voxel_coords_step = to_color(vec3(voxel.coords_step) * 0.5 + 0.5); 

// entry distance
vec4 debug_voxel_entry_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, voxel.entry_distance)); 

// exit distance
vec4 debug_voxel_exit_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, voxel.exit_distance)); 

// span distance
vec4 debug_voxel_span_distance = to_color((voxel.exit_distance - voxel.entry_distance) / u_intensity_map.spacing_length); 

// min position
vec4 debug_voxel_min_position = to_color(map(box.min_position, box.max_position, voxel.min_position)); 

// max position
vec4 debug_voxel_max_position = to_color(map(box.min_position, box.max_position, voxel.max_position)); 

// PRINT DEBUG

switch (u_debugging.option - debug_slot_voxel)
{ 
    case  1: fragColor = debug_voxel_occupied;       break;
    case  2: fragColor = debug_voxel_intersected;    break;
    case  3: fragColor = debug_voxel_terminated;     break;
    case  4: fragColor = debug_voxel_coords;         break;
    case  5: fragColor = debug_voxel_coords_step;    break;
    case  6: fragColor = debug_voxel_max_position;   break;
    case  7: fragColor = debug_voxel_min_position;   break;
    case  8: fragColor = debug_voxel_entry_distance; break;
    case  9: fragColor = debug_voxel_exit_distance;  break;
    case 10: fragColor = debug_voxel_span_distance;  break;
}

