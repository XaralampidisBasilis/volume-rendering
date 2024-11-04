
// set up the coefficients for the cubic Taylor approximation at the trace position.
vec4 taylor_coeffs = vec4(trace.sample_error, trace.derivative_1st, trace.derivative_2nd / 2.0, trace.derivative_3rd / 6.0);

// make change of variable to directly compute the next stepping and not spacing
taylor_coeffs *= vec4(1.0, ray.step_distance, pow2(ray.step_distance), pow3(ray.step_distance));

// solve the cubic taylor polynomial for the spacing value.
int num_roots; vec3 next_stepping = cubic_roots(taylor_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(vec3(ray.max_step_scaling), next_stepping, greaterThan(next_stepping, vec3(0.0)));
next_stepping = mix(vec3(ray.max_step_scaling), next_stepping, bvec3(num_roots > 0));

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.step_scaling = mmin(next_stepping);
trace.step_scaling = clamp(trace.step_scaling, ray.min_step_scaling, ray.max_step_scaling);

