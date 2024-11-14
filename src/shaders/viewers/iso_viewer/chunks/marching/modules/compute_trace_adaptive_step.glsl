#if TRACE_STEP_SCALING_ENABLED == 1

    // compute step distance based on taylor expansion  
    trace.step_distance = -trace.sample_error / trace.derivative;

    // set negative values to max step distance.
    trace.step_distance = trace.derivative > 0.0 ? trace.step_distance : ray.max_step_distance;

    // choose the minimum valid solution and clamp the result between the allowable stepping range.
    trace.step_distance = clamp(trace.step_distance, ray.min_step_distance, ray.max_step_distance);
    trace.step_scaling = trace.step_distance / ray.step_distance;
#endif

#if TRACE_STEP_STRETCHING_ENABLED == 1

    // exponential distance stretching profile
    float camera_angle = dot(ray.step_direction, ray.camera_direction);
    trace.step_stretching = 2.0 - smoothstep(0.8, 1.0, camera_angle);
    trace.step_stretching *= clamp(trace.distance * u_volume.size_length * 2.0, 0.0, 1.0);

    trace.step_distance *= trace.step_stretching;
    trace.step_distance = clamp(trace.step_distance, ray.min_step_distance, ray.max_step_distance);
#endif
