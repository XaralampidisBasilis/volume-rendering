
float debug_trace_mean_step_scaling = map(ray.min_step_scaling, ray.max_step_scaling, trace.distance / ray.step_distance / float(trace.step_count + 1));

debug.trace_mean_step_scaling = vec4(vec3(debug_trace_mean_step_scaling), 1.0);
