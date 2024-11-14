
// divide by ray step distance to get scaling 
trace.step_scaling = -trace.sample_error / maxabs(trace.derivative, MICRO_TOLERANCE);
trace.step_scaling /= ray.step_distance;

// set negative values toto max step scaling.
trace.step_scaling = mix(trace.max_step_scaling, trace.step_scaling, trace.step_scaling > 0.0);

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.step_scaling = clamp(trace.step_scaling, trace.min_step_scaling, trace.max_step_scaling);
