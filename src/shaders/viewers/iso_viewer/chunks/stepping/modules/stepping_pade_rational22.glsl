
// solve the equation of pade[2,2](x) == fc to find the next_spacing, this equation results in a quadratic
// we assume trace.derivative4 = 0
vec2 mixed = vec2(
    2.0 * trace.derivative * trace.derivative3 - 3.0 * pow2(trace.derivative2),
    3.0 * trace.derivative * trace.derivative2 - trace.error * trace.derivative3
);

vec3 pade_coeffs = vec3(
    6.0 * trace.error * mixed.x, 
    6.0 * (trace.derivative * mixed.x + trace.error *  trace.derivative2 * trace.derivative3),
    3.0 * trace.derivative2 * mixed.x + 2.0 * trace.derivative3 * mixed.y
);

// make change of variable to directly compute the next stepping and not spacing
pade_coeffs *= vec3(1.0, ray.spacing, pow2(ray.spacing));

// solve the quadratic polynomial for the stepping value.
int num_roots; vec2 next_stepping = quadratic_roots(pade_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(vec2(u_raycast.max_stepping), next_stepping, greaterThan(next_stepping, vec2(0.0)));
next_stepping = mix(vec2(u_raycast.max_stepping), next_stepping, bvec2(num_roots > 0));

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.stepping = mmin(next_stepping);
trace.stepping = clamp(trace.stepping, u_raycast.min_stepping, u_raycast.max_stepping);
