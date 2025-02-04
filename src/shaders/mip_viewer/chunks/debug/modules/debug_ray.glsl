// COMPUTE DEBUG 

// discarded
vec4 debug_ray_discarded = to_color(ray.discarded);

// ray direction
vec4 debug_ray_direction = to_color(ray.direction * 0.5 + 0.5);

// step distance
vec4 debug_ray_step_distance = to_color(ray.step_distance / u_intensity_map.spacing_length);

// start distance
vec4 debug_ray_start_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, ray.start_distance));

// end distance
vec4 debug_ray_end_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, ray.end_distance));

// span distance
vec4 debug_ray_span_distance = to_color(map(0.0, box.max_span_distance, ray.span_distance));

// start position
vec4 debug_ray_start_position = to_color(map(box.min_position, box.max_position, ray.start_position));

// end position
vec4 debug_ray_end_position = to_color(map(box.min_position, box.max_position, ray.end_position));

// max cell count
vec4 debug_ray_max_cell_count = to_color(float(ray.max_cell_count) / float(u_rendering.max_cell_count));

// max block count
vec4 debug_ray_max_block_count = to_color(float(ray.max_block_count) / float(u_rendering.max_block_count));


// PRINT DEBUG

switch (u_debugging.option - debug.slot_ray)
{
    case  1: fragColor = debug_ray_discarded;       break;
    case  2: fragColor = debug_ray_direction;       break;
    case  3: fragColor = debug_ray_step_distance;   break;
    case  4: fragColor = debug_ray_start_distance;  break;
    case  5: fragColor = debug_ray_end_distance;    break;
    case  6: fragColor = debug_ray_span_distance;   break;
    case  7: fragColor = debug_ray_start_position;  break;
    case  8: fragColor = debug_ray_end_position;    break;
    case  9: fragColor = debug_ray_max_cell_count;  break;
    case 10: fragColor = debug_ray_max_block_count; break;
}