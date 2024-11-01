
// normalize trace step distance to the range [0, 1]
float debug_trace_step_distance = trace.step_distance;
debug_trace_step_distance /= length(volume.spacing);

debug.trace_step_distance = vec4(vec3(debug_trace_step_distance), 1.0);
