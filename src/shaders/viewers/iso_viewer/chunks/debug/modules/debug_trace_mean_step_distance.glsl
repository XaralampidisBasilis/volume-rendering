
// normalize trace step distance to the range [0, 1]
float debug_trace_mean_step_distance = trace.stepped_distance / float(trace.step_count);

debug.trace_mean_step_distance = vec4(vec3(debug_trace_mean_step_distance), 1.0);
