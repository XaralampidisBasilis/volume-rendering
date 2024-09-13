
#if STEPPING_METHOD == 4

    float steepness = map(u_gradient.min_norm, u_gradient.max_norm, trace.gradient_norm);
    trace.stepping = mix(u_raycast.max_stepping, u_raycast.min_stepping, steepness);

#endif

