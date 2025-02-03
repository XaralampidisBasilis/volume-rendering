
// COMPUTE DEBUG

// terminated
vec4 debug_cell_terminated = vec4(vec3(cell.terminated), 1.0);

// terminated
vec4 debug_cell_saturated = vec4(vec3(cell.saturated), 1.0);

// coords
vec4 debug_cell_coords = vec4(vec3(0.0), 1.0) 
debug_cell_coords.xyz = vec3(cell.coords) * u_intensity_map.inv_dimensions;

// coords step
vec4 debug_cell_coords = vec4(vec3(0.0), 1.0); 
debug_cell_coords_step.xyz = vec3(cell.coords_step) * 0.5 + 0.5;

// entry distance
vec4 debug_cell_entry_distance = vec4(vec3(0.0), 1.0); 
debug_cell_entry_distance.xyz = vec3(map(box.min_entry_distance, box.max_exit_distance, cell.entry_distance));

// exit distance
vec4 debug_cell_exit_distance = vec4(vec3(0.0), 1.0); 
debug_cell_entry_distance.xyz = vec3(map(box.min_entry_distance, box.max_exit_distance, cell.exit_distance));

// span distance
vec4 debug_cell_span_distance = vec4(vec3(0.0), 1.0); 
debug_cell_span_distance.xyz = vec3((cell.exit_distance - cell.entry_distance) / u_intensity_map.spacing_length);

// min position
vec4 debug_cell_min_position = vec4(vec3(0.0), 1.0); 
debug_cell_min_position.xyz = map(box.min_position, box.max_position, cell.min_position);

// max position
vec4 debug_cell_max_position = vec4(vec3(0.0), 1.0); 
debug_cell_max_position.xyz = map(box.min_position, box.max_position, cell.max_position);

// sample distances
vec4 debug_cell_sample_distances = vec4(vec3(0.0), 1.0); 
debug_cell_sample_distances.xyz = map(cell.entry_distance, cell.exit_distance, cell.sample_distances.xyz);

// sample intensities
vec4 debug_cell_sample_intensities = vec4(vec3(0.0), 1.0)
debug_cell_sample_intensities.xyz = vec3(cell.sample_intensities.xyz);

// intensity coefficients
vec4 debug_cell_intensity_coeffs = vec4(vec3(0.0), 1.0); 
debug_cell_intensity_coeffs.xyz = vec3(cell.intensity_coeffs.xyz/cell.intensity_coeffs.w);

// PRINT DEBUG

switch (u_debugging.option - debug.slot_cell)
{ 
    case  1: fragColor = debug_cell_terminated;         break;
    case  2: fragColor = debug_cell_saturated;          break;
    case  3: fragColor = debug_cell_coords;             break;
    case  4: fragColor = debug_cell_coords_step;        break;
    case  5: fragColor = debug_cell_max_position;       break;
    case  6: fragColor = debug_cell_min_position;       break;
    case  7: fragColor = debug_cell_entry_distance;     break;
    case  8: fragColor = debug_cell_exit_distance;      break;
    case  9: fragColor = debug_cell_span_distance;      break;
    case 10: fragColor = debug_cell_sample_distances;   break;
    case 11: fragColor = debug_cell_sample_intensities; break;
    case 12: fragColor = debug_cell_intensity_coeffs;   break;
}

