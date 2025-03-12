
// COMPUTE DEBUG 

// exhausted
vec4 debug_trace_intersected = to_color(trace.intersected);

// terminated 
vec4 debug_trace_terminated = to_color(trace.terminated);

// exhausted 
vec4 debug_trace_exhausted = to_color(trace.exhausted);

// outside
vec4 debug_trace_outside = to_color(outside_open_box(0.0, 1.0, map(box.min_position, box.max_position, trace.position)));

// distance
vec4 debug_trace_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, trace.distance));

// position
vec4 debug_trace_position = to_color(map(box.min_position, box.max_position, trace.position));

// intensity 
vec4 debug_trace_intensity = to_color(trace.intensity);

// gradient
vec4 debug_trace_gradient = to_color((trace.gradient / mmax(u_volume.inv_spacing)) * 0.5 + 0.5);

// gradient length
vec4 debug_trace_gradient_length = to_color(map(0.0, mmax(u_volume.inv_spacing), length(trace.gradient)));

// PRINT DEBUG

switch (u_debugging.option - debug_slot_trace)
{ 
    case 1: fragColor = debug_trace_terminated;      break;
    case 2: fragColor = debug_trace_intersected;     break;
    case 3: fragColor = debug_trace_exhausted;       break;
    case 4: fragColor = debug_trace_outside;         break;
    case 5: fragColor = debug_trace_distance;        break;
    case 6: fragColor = debug_trace_position;        break;
    case 7: fragColor = debug_trace_intensity;       break;
    case 8: fragColor = debug_trace_gradient;        break;
    case 9: fragColor = debug_trace_gradient_length; break;
}