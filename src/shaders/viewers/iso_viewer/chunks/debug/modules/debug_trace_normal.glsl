
// normalize trace normal to the range [0, 1]
vec3 trace_normal_norm = trace.normal * 0.5 + 0.5;

debug.trace_normal = vec4(trace_normal_norm, 1.0);
