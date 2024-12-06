
// normalize trace traversed to the range [0, 1]
float debug_trace_stepped_distance = trace.stepped_distance / box.max_span_distance;

debug.trace_stepped_distance = vec4(vec3(debug_trace_stepped_distance), 1.0);
