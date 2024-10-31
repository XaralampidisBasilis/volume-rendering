
// normalize trace total count to the range [0, 1]
float debug_trace_total_count = float(trace.step_count + trace.skip_count) / float(raymarch.max_step_count + raymarch.max_skip_count);

debug.trace_total_count = vec4(vec3(debug_trace_total_count), 1.0);
