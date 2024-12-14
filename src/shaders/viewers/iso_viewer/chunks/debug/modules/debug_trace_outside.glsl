

float debug_trace_outside = outside_closed_box(0.0, 1.0, 
    map(box.min_position, box.max_position, trace.position)
);

debug.trace_outside = vec4(vec3(debug_trace_outside), 1.0);
