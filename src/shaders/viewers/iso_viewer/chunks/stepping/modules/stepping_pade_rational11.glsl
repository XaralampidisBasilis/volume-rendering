
// calculate the slope of the derivative between the current and previous trace.
float slope = (trace.value - prev_trace.value) / trace.spacing;

// compute the second derivative using Hermitian cubic interpolation.
float second_derivative = (2.0 * trace.derivative + prev_trace.derivative - 3.0 * slope) * 2.0;
second_derivative /= trace.stepping;

// set up the linear coefficients resulting for the equation pade[1,1] == fc.
vec2 pade_coeffs = vec2(
    2.0 * trace.derivative * trace.error,
    2.0 * trace.derivative * trace.derivative - second_derivative * trace.error
);

// make change of variable to directly compute the next stepping and not spacing
pade_coeffs *= vec2(1.0, ray.spacing);

// solve the cubic taylor polynomial for the spacing value.
int num_roots; float next_stepping = linear_roots(pade_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(u_raycast.max_stepping, next_stepping, next_stepping > 0.0);
next_stepping = mix(u_raycast.max_stepping, next_stepping, num_roots > 0);

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.stepping = clamp(next_stepping, u_raycast.min_stepping, u_raycast.max_stepping);
