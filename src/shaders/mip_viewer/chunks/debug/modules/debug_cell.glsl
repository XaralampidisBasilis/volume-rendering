
// COMPUTE DEBUG

// intersected 
debug.cell_intersected = vec4(vec3(cell.intersected), 1.0);

// terminated
debug.cell_terminated = vec4(vec3(cell.terminated), 1.0);

// coords
vec3 debug_cell_coords = vec3(cell.coords) * u_intensity_map.inv_dimensions;
debug.cell_coords = vec4(debug_cell_coords, 1.0);

// coords step
vec3 debug_cell_coords_step = vec3(cell.coords_step) * 0.5 + 0.5;
debug.cell_coords_step  = vec4(debug_cell_coords_step, 1.0);

// entry distance
float debug_cell_entry_distance = map(box.min_entry_distance, box.max_exit_distance, cell.entry_distance);
debug.cell_entry_distance = vec4(vec3(debug_cell_entry_distance), 1.0);

// exit distance
float debug_cell_exit_distance = map(box.min_entry_distance, box.max_exit_distance, cell.exit_distance);
debug.cell_exit_distance = vec4(vec3(debug_cell_exit_distance), 1.0);

// span distance
float debug_cell_span_distance = (cell.exit_distance - cell.entry_distance) / u_intensity_map.spacing_length;
debug.cell_span_distance = vec4(vec3(debug_cell_span_distance), 1.0);
 
// min position
vec3 debug_cell_min_position = map(box.min_position, box.max_position, cell.min_position);
debug.cell_min_position = vec4(debug_cell_min_position, 1.0);

// max position
vec3 debug_cell_max_position = map(box.min_position, box.max_position, cell.max_position);
debug.cell_max_position = vec4(debug_cell_max_position, 1.0);

// sample distances
vec4 debug_cell_sample_distances = map(cell.entry_distance, cell.exit_distance, cell.sample_distances);
debug.cell_sample_distances = vec4(debug_cell_sample_distances.xyz, 1.0);

// sample intensities
debug.cell_sample_intensities = vec4(vec3(cell.sample_intensities.xyz), 1.0);

// intensity coefficients
debug.cell_intensity_coeffs = vec4(vec3(cell.intensity_coeffs.xyz/cell.intensity_coeffs.w), 1.0);


// PRINT DEBUG

switch (u_debugging.option - debug.slot_cell)
{ 
    case  1: fragColor = debug.cell_intersected;        break;
    case  2: fragColor = debug.cell_terminated;         break;
    case  3: fragColor = debug.cell_coords;             break;
    case  4: fragColor = debug.cell_coords_step;        break;
    case  5: fragColor = debug.cell_max_position;       break;
    case  6: fragColor = debug.cell_min_position;       break;
    case  7: fragColor = debug.cell_entry_distance;     break;
    case  8: fragColor = debug.cell_exit_distance;      break;
    case  9: fragColor = debug.cell_span_distance;      break;
    case 10: fragColor = debug.cell_sample_distances;   break;
    case 11: fragColor = debug.cell_sample_intensities; break;
    case 12: fragColor = debug.cell_intensity_coeffs;   break;
}

