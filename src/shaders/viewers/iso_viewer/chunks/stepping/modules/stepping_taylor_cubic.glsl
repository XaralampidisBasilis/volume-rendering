

// compute the second and third derivative using Hermitian cubic interpolation.
float slope = (trace.value - prev_trace.value) / trace.spacing;

float second_derivative = (2.0 * trace.derivative + prev_trace.derivative - 3.0 * slope) * 2.0;
second_derivative /= trace.spacing;

float third_derivative = (trace.derivative + prev_trace.derivative - 3.0 * slope) * 6.0;
third_derivative /= pow2(trace.spacing);

// set up the coefficients for the cubic Taylor approximation at the trace position.
vec4 taylor_coeffs = vec4(trace.error, trace.derivative, second_derivative / 2.0, third_derivative / 6.0);

// make change of variable to directly compute the next stepping and not spacing
taylor_coeffs *= vec4(1.0, ray.spacing, pow2(ray.spacing), pow3(ray.spacing));

// solve the cubic taylor polynomial for the spacing value.
int num_roots; vec3 next_stepping = cubic_roots(taylor_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(vec3(u_raycast.max_stepping), next_stepping, greaterThan(next_stepping, vec3(0.0)));
next_stepping = mix(vec3(u_raycast.max_stepping), next_stepping, bvec3(num_roots > 0));

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.stepping = mmin(next_stepping);
trace.stepping = clamp(trace.stepping, u_raycast.min_stepping, u_raycast.max_stepping);



debug.variable3 = vec4(vec3(num_roots) / 3.0, 1.0);
