
// normalize trace skip distance to the range [0, 1]
float debug_trace_skip_distance = trace.skip_distance / length(occumap.spacing);

debug.trace_skip_distance = vec4(vec3(debug_trace_skip_distance), 1.0);
