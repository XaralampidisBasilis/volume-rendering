
// COMPUTE DEBUG 

// intersected
debug.trace_intersected = vec4(vec3(trace.intersected), 1.0);

// exhausted
debug.trace_exhausted = vec4(vec3(trace.exhausted), 1.0);

// terminated 
debug.trace_terminated = vec4(vec3(trace.terminated), 1.0);

// outside
float debug_trace_outside = outside_open_box(0.0, 1.0, map(box.min_position, box.max_position, trace.position));
debug.trace_outside = vec4(vec3(debug_trace_outside), 1.0);

// distance
vec3 debug_trace_distance = map(box.min_entry_distance, box.max_exit_distance, vec3(trace.distance));
debug_trace_distance = mmix(RED_COLOR, BLACK_COLOR, WHITE_COLOR, map(-1.0, 1.0, debug_trace_distance));
debug.trace_distance = vec4(debug_trace_distance, 1.0);

// position
vec3 debug_trace_position = map(box.min_position, box.max_position, trace.position);
debug.trace_position = vec4(debug_trace_position, 1.0);

// intensity 
debug.trace_intensity = vec4(vec3(trace.intensity), 1.0);

// error
vec3 debug_trace_error = mmix(BLUE_COLOR, BLACK_COLOR, RED_COLOR, map(-1.0, 1.0, trace.error / MILLI_TOLERANCE));
debug.trace_error = vec4(debug_trace_error, 1.0);

// abs error
vec3 debug_trace_abs_error = mmix(BLACK_COLOR, RED_COLOR, abs(trace.error / MILLI_TOLERANCE));
debug.trace_abs_error = vec4(debug_trace_abs_error, 1.0);

// gradient
vec3 debug_trace_gradient = (trace.gradient / mmax(u_intensity_map.inv_spacing)) * 0.5 + 0.5;
debug.trace_gradient = vec4(debug_trace_gradient, 1.0);

// gradient length
float debug_trace_gradient_length = map(0.0, mmax(u_intensity_map.inv_spacing), length(trace.gradient));
debug.trace_gradient_length = vec4(vec3(debug_trace_gradient_length), 1.0);

// PRINT DEBUG

switch (u_debugging.option - debug.slot_trace)
{ 
    case  1: fragColor = debug.trace_intersected;     break;
    case  2: fragColor = debug.trace_terminated;      break;
    case  3: fragColor = debug.trace_exhausted;       break;
    case  4: fragColor = debug.trace_outside;         break;
    case  5: fragColor = debug.trace_distance;        break;
    case  6: fragColor = debug.trace_position;        break;
    case  7: fragColor = debug.trace_intensity;       break;
    case  8: fragColor = debug.trace_error;           break;
    case  9: fragColor = debug.trace_abs_error;       break;
    case 10: fragColor = debug.trace_gradient;        break;
    case 11: fragColor = debug.trace_gradient_length; break;
}