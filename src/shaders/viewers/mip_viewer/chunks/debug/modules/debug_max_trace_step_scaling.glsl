
float debug_max_trace_step_scaling = map(ray.min_step_scaling, ray.max_step_scaling, max_trace.step_scaling);

debug.max_trace_step_scaling = vec4(vec3(debug_max_trace_step_scaling), 1.0);
