
// COMPUTE DEBUG 

// exhausted
vec4 debug_mip_exhausted = to_color(mip.exhausted);

// terminated 
vec4 debug_mip_terminated = to_color(mip.terminated);

// outside
vec4 debug_mip_outside = to_color(outside_open_box(0.0, 1.0, map(box.min_position, box.max_position, mip.position)));

// distance
vec4 debug_mip_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, mip.distance));

// position
vec4 debug_mip_position = to_color(map(box.min_position, box.max_position, mip.position));

// intensity 
vec4 debug_mip_intensity = to_color(mip.intensity);

// error
vec4 debug_mip_error = to_color(mmix(BLUE_COLOR, BLACK_COLOR, RED_COLOR, map(-1.0, 1.0, mip.error / MILLI_TOLERANCE)));

// abs error
vec4 debug_mip_abs_error = to_color(mmix(BLACK_COLOR, RED_COLOR, abs(mip.error / MILLI_TOLERANCE)));

// gradient
vec4 debug_mip_gradient = to_color((mip.gradient / mmax(u_intensity_map.inv_spacing)) * 0.5 + 0.5);

// gradient length
vec4 debug_mip_gradient_length = to_color(map(0.0, mmax(u_intensity_map.inv_spacing), length(mip.gradient)));

// PRINT DEBUG

switch (u_debugging.option - debug_slot_mip)
{ 
    case  1: fragColor = debug_mip_terminated;      break;
    case  2: fragColor = debug_mip_exhausted;       break;
    case  3: fragColor = debug_mip_outside;         break;
    case  4: fragColor = debug_mip_distance;        break;
    case  5: fragColor = debug_mip_position;        break;
    case  6: fragColor = debug_mip_intensity;       break;
    case  7: fragColor = debug_mip_error;           break;
    case  8: fragColor = debug_mip_abs_error;       break;
    case  9: fragColor = debug_mip_gradient;        break;
    case 10: fragColor = debug_mip_gradient_length; break;
}