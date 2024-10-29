
// compute trace luminance
float debug_trace_luminance = dot(trace.shaded_color, vec3(0.2126, 0.7152, 0.0722));

debug.trace_luminance = vec4(vec3(debug_trace_luminance), 1.0);
