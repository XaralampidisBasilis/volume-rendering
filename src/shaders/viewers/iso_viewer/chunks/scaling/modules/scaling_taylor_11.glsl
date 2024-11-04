
// set up the linear coefficients resulting for the equation pade[1,1] == fc.
vec2 pade_coeffs = vec2(
    2.0 * trace.derivative_1st * trace.sample_error,
    2.0 * trace.derivative_1st * trace.derivative_1st - trace.derivative_2nd * trace.sample_error
);

// make change of variable to directly compute the next stepping and not spacing
pade_coeffs *= vec2(1.0, ray.step_distance);

// solve the cubic taylor polynomial for the spacing value.
int num_roots; float next_stepping = linear_roots(pade_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(ray.max_step_scaling, next_stepping, next_stepping > 0.0);
next_stepping = mix(ray.max_step_scaling, next_stepping, num_roots > 0);

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.step_scaling = clamp(next_stepping, ray.min_step_scaling, ray.max_step_scaling);

