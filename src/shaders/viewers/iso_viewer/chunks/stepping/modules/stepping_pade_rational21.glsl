
// calculate the slope of the derivative between the current and previous trace.
float slope = (trace.value - prev_trace.value) / trace.spacing;

// compute the second derivative using Hermitian cubic interpolation.
float second_derivative = (2.0 * trace.derivative + prev_trace.derivative - 3.0 * slope) * 2.0;
second_derivative /= trace.spacing;

float third_derivative = (trace.derivative + prev_trace.derivative - 2.0 * slope) * 6.0;
third_derivative /= pow2(trace.spacing);

// solve the equation of pade[2,1](x) == fc to find the next_spacing, this equation results in a quadratic
vec3 pade_coeffs = vec3(
    6.0 * second_derivative * trace.error, 
    6.0 * second_derivative * trace.derivative - 2.0 * third_derivative * trace.error,
    3.0 * second_derivative * second_derivative - 2.0 * third_derivative * trace.derivative
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
