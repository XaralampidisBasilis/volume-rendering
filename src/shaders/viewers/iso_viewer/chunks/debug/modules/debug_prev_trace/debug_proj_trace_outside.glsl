

float debug_proj_trace_outside = outside_open_box(0.0, 1.0, 
    map(box.min_position, box.max_position, proj_trace.position)
);

debug.proj_trace_outside = vec4(vec3(debug_proj_trace_outside), 1.0);
