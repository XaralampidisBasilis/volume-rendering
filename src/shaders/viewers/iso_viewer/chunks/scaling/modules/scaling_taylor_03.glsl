
// solve the equation of pade[0,3](x) == fc to find the next_spacing, this equation results in a cubic
vec2 mixed_terms = vec2(
    trace.derivative_2nd * trace.sample_value - 2.0 * trace.derivative_1st * trace.derivative_1st,
    trace.derivative_3rd * trace.sample_value - 3.0 * trace.derivative_2nd * trace.derivative_1st
);

vec4 pade_coeffs = vec4(
    6.0 * pow3(trace.sample_value) * trace.sample_error, 
    6.0 * pow2(trace.sample_value) * trace.derivative_1st * raymarch.sample_threshold, 
    3.0 * trace.sample_value * mixed_terms.x * raymarch.sample_threshold,
    (trace.sample_value * mixed_terms.y - 3.0 * trace.derivative_1st * mixed_terms.x) * raymarch.sample_threshold
);

// make change of variable to directly compute the next stepping and not spacing
pade_coeffs *= vec4(1.0, ray.step_distance, pow2(ray.step_distance), pow3(ray.step_distance));

// solve the quadratic polynomial for the stepping value.
int num_roots; vec3 next_stepping = cubic_roots(pade_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(vec3(ray.max_step_scaling), next_stepping, greaterThan(next_stepping, vec3(0.0)));
next_stepping = mix(vec3(ray.max_step_scaling), next_stepping, bvec3(num_roots > 0));

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.step_scaling = mmin(next_stepping);
trace.step_scaling = clamp(trace.step_scaling, ray.min_step_scaling, ray.max_step_scaling);

