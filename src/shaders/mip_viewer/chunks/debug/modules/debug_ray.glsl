// COMPUTE DEBUG 

// discarded
debug.ray_discarded = vec4(vec3(ray.discarded), 1.0);

// step direction
vec3 debug_ray_direction = ray.direction * 0.5 + 0.5;
debug.ray_direction = vec4(debug_ray_direction, 1.0);

// step distance
float debug_ray_step_distance = ray.step_distance / u_intensity_map.spacing_length;
debug.ray_step_distance = vec4(vec3(debug_ray_step_distance), 1.0);

// start distance
float debug_ray_start_distance = map(box.min_entry_distance, box.max_exit_distance, ray.start_distance);
debug.ray_start_distance = vec4(vec3(debug_ray_start_distance), 1.0);

// end distance
float debug_ray_end_distance = map(box.min_entry_distance, box.max_exit_distance, ray.end_distance);
debug.ray_end_distance = vec4(vec3(debug_ray_end_distance), 1.0);

// span distance
float debug_ray_span_distance = map(0.0, box.max_span_distance, ray.span_distance);
debug.ray_span_distance = vec4(vec3(debug_ray_span_distance), 1.0);

// start position
vec3 debug_ray_start_position =  map(box.min_position, box.max_position, ray.start_position);
debug.ray_start_position = vec4(vec3(debug_ray_start_position), 1.0);

// end position
vec3 debug_ray_end_position = map(box.min_position, box.max_position, ray.end_position);
debug.ray_end_position = vec4(vec3(debug_ray_end_position), 1.0);

// max cell count
float debug_ray_max_cell_count = float(ray.max_cell_count) / float(u_rendering.max_cell_count);
debug.ray_max_cell_count = vec4(vec3(debug_ray_max_cell_count), 1.0);

// max block count
float debug_ray_max_block_count = float(ray.max_block_count) / float(u_rendering.max_block_count);
debug.ray_max_block_count = vec4(vec3(debug_ray_max_block_count), 1.0);


// PRINT DEBUG

switch (u_debugging.option - debug.slot_ray)
{
    case  1: fragColor = debug.ray_discarded;       break;
    case  2: fragColor = debug.ray_direction;       break;
    case  3: fragColor = debug.ray_step_distance;   break;
    case  4: fragColor = debug.ray_start_distance;  break;
    case  5: fragColor = debug.ray_end_distance;    break;
    case  6: fragColor = debug.ray_span_distance;   break;
    case  7: fragColor = debug.ray_start_position;  break;
    case  8: fragColor = debug.ray_end_position;    break;
    case  9: fragColor = debug.ray_max_cell_count;  break;
    case 10: fragColor = debug.ray_max_block_count; break;
}