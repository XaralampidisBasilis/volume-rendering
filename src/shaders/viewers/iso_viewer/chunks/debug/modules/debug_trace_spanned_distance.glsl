
// normalize trace spanned to the range [0, 1]
float debug_trace_spanned_distance = trace.spanned_distance / ray.max_span_distance;

debug.trace_spanned_distance = vec4(vec3(debug_trace_spanned_distance), 1.0);