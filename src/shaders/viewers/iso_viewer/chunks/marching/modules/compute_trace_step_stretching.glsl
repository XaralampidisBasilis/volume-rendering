
// exponential stretching profile
trace.step_stretching = exp(trace.distance * u_volume.size_length * 2.0);
trace.step_stretching = clamp(trace.step_stretching - 1.0, 0.0, 1.0);

// linear stretching profile
// trace.step_stretching = 2.0 * trace.distance * u_volume.size_length;
// trace.step_stretching = clamp(trace.step_stretching, 0.0, 1.0);

// step stretching bounds 
ray.min_step_stretching = sinkstep(0.0, 1.0, trace.step_stretching, 0.5);
ray.max_step_stretching = hillstep(0.0, 1.0, trace.step_stretching, 0.5);
ray.span_step_stretching = ray.max_step_stretching - ray.min_step_stretching;

// strech step scaling interval the more distant the trace becomes
ray.min_step_scaling = mix(u_raymarch.min_step_scaling, u_raymarch.max_step_scaling, ray.min_step_stretching);
ray.max_step_scaling = mix(u_raymarch.min_step_scaling, u_raymarch.max_step_scaling, ray.max_step_stretching);

