
// solve taylor linear equation to get trace step distance approximation
float trace_step_distance = - trace.sample_error / maxabs(trace.derivative, MICRO_TOLERANCE);

// divide by ray step distance to get scaling 
trace.step_scaling = trace_step_distance / ray.step_distance;

// set negative values toto max step scaling.
trace.step_scaling = mix(RAY_MAX_STEP_SCALING, trace.step_scaling, trace.step_scaling > 0.0);

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.step_scaling = clamp(trace.step_scaling, RAY_MIN_STEP_SCALING, RAY_MAX_STEP_SCALING);
