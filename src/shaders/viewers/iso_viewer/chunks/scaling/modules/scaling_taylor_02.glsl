
// solve the equation of pade[0,2](x) == fc to find the next_spacing, this equation results in a quadratic
vec3 pade_coeffs = vec3(
    2.0 * trace.sample_value * trace.sample_value * trace.sample_error, 
    2.0 * trace.sample_value * trace.derivative_1st * raymarch.sample_threshold,
   (trace.sample_value * trace.derivative_2nd - 2.0 * trace.derivative_1st * trace.derivative_1st) * raymarch.sample_threshold
);

// make change of variable to directly compute the next stepping and not spacing
pade_coeffs *= vec3(1.0, ray.step_distance, pow2(ray.step_distance));

// solve the quadratic polynomial for the stepping value.
int num_roots; vec2 next_stepping = quadratic_roots(pade_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(vec2(raymarch.max_step_scaling), next_stepping, greaterThan(next_stepping, vec2(0.0)));
next_stepping = mix(vec2(raymarch.max_step_scaling), next_stepping, bvec2(num_roots > 0));

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.step_scaling = mmin(next_stepping);
trace.step_scaling = clamp(trace.step_scaling, raymarch.min_step_scaling, raymarch.max_step_scaling);
