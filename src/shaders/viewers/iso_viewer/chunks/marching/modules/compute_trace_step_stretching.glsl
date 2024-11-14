
// exponential stretching profile
trace.step_stretching = exp(trace.distance * u_volume.size_length * 2.0);
trace.step_stretching = clamp(trace.step_stretching - 1.0, 0.0, 1.0);
trace.step_stretching *= 2.0 - smoothstep(0.8, 1.0, dot(ray.step_direction, ray.camera_direction));

// step stretching bounds 
trace.min_step_stretching = sinkstep(0.0, 1.0, trace.step_stretching, 0.5);
trace.max_step_stretching = hillstep(0.0, 1.0, trace.step_stretching, 0.5);
trace.range_step_stretching = trace.max_step_stretching - trace.min_step_stretching;

// strech step scaling interval the more distant the trace becomes
trace.min_step_scaling = mix(ray.min_step_scaling, ray.max_step_scaling, trace.min_step_stretching);
trace.max_step_scaling = mix(ray.min_step_scaling, ray.max_step_scaling, trace.max_step_stretching);

