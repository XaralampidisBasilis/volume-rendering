
// solve taylor linear equation 
trace.step_scaling = - trace.sample_error / maxabs(trace.derivative_1st, MICRO_TOL);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
trace.step_scaling = mix(raymarch.max_step_scaling + MICRO_TOL, trace.step_scaling, trace.step_scaling > 0.0);

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.step_scaling = clamp(trace.step_scaling, raymarch.min_step_scaling - MICRO_TOL, raymarch.max_step_scaling + MICRO_TOL);
