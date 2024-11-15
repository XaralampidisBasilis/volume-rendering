// compute step distance based on taylor expansion  
trace.step_distance = u_raymarch.step_speed / trace.derivative;

// set negative values to max step distance.
trace.step_distance = trace.derivative > 0.0 ? trace.step_distance : ray.max_step_distance;

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.step_distance = clamp(trace.step_distance, ray.min_step_distance, ray.max_step_distance);
trace.step_scaling = trace.step_distance / ray.step_distance;
