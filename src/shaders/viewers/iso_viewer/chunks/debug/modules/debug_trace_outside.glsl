

float is_trace_outside = outside_box(0.0, 1.0, trace.texel);

debug.trace_outside = vec4(vec3(is_trace_outside), 1.0);
