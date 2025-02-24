
// COMPUTE DEBUG

// terminated
vec4 debug_cell_terminated = to_color(cell.terminated);

// terminated
vec4 debug_cell_saturated = to_color(cell.saturated);

// coords
vec4 debug_cell_coords = to_color(vec3(cell.coords) * u_intensity_map.inv_dimensions);

// coords step
vec4 debug_cell_coords_step = to_color(vec3(cell.coords_step) * 0.5 + 0.5); 

// entry distance
vec4 debug_cell_entry_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, cell.entry_distance)); 

// exit distance
vec4 debug_cell_exit_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, cell.exit_distance)); 

// span distance
vec4 debug_cell_span_distance = to_color((cell.exit_distance - cell.entry_distance) / u_intensity_map.spacing_length); 

// min position
vec4 debug_cell_min_position = to_color(map(box.min_position, box.max_position, cell.min_position)); 

// max position
vec4 debug_cell_max_position = to_color(map(box.min_position, box.max_position, cell.max_position)); 

// sample distances
vec4 debug_cell_sample_distances = to_color(map(cell.entry_distance, cell.exit_distance, cell.sample_distances.xyz)); 

// sample intensities
vec4 debug_cell_sample_intensities = to_color(cell.sample_intensities.xyz);

// intensity coefficients
vec4 debug_cell_intensity_coeffs = to_color(cell.intensity_coeffs.xyz/cell.intensity_coeffs.w); 

// PRINT DEBUG

switch (u_debugging.option - debug_slot_cell)
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

