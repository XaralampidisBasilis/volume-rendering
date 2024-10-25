
// solve the equation of pade[0,3](x) == fc to find the next_spacing, this equation results in a cubic
vec2 mixed_terms = vec2(
    trace.derivative2 * trace.value - 2.0 * trace.derivative * trace.derivative,
    trace.derivative3 * trace.value - 3.0 * trace.derivative2 * trace.derivative
);

vec4 pade_coeffs = vec4(
    6.0 * pow3(trace.value) * trace.error, 
    6.0 * pow2(trace.value) * trace.derivative * u_raycast.threshold, 
    3.0 * trace.value * mixed_terms.x * u_raycast.threshold,
    (trace.value * mixed_terms.y - 3.0 * trace.derivative * mixed_terms.x) * u_raycast.threshold
);

// make change of variable to directly compute the next stepping and not spacing
pade_coeffs *= vec4(1.0, ray.spacing, pow2(ray.spacing), pow3(ray.spacing));

// solve the quadratic polynomial for the stepping value.
int num_roots; vec3 next_stepping = cubic_roots(pade_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(vec3(u_raycast.max_stepping), next_stepping, greaterThan(next_stepping, vec3(0.0)));
next_stepping = mix(vec3(u_raycast.max_stepping), next_stepping, bvec3(num_roots > 0));

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.stepping = mmin(next_stepping);
trace.stepping = clamp(trace.stepping, u_raycast.min_stepping, u_raycast.max_stepping);

