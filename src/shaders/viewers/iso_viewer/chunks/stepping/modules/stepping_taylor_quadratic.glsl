
// STEPPING_TAYLOR2
/**
 * Uses Hermitian cubic interpolation to approximate the second derivative at the trace position 
 * and computes the quadratic Taylor approximation to solve for the stepping value.
 *
 * @input trace.value              : current trace value at the ray's position (float)
 * @input trace.derivative         : current derivative at the trace position (float)
 * @input trace.spacing            : spacing between the current and previous trace (float)
 * @input prev_trace.value         : previous trace value (float)
 * @input prev_trace.derivative    : previous derivative at the trace position (float)
 * @input ray.spacing              : the spacing size for ray marching steps (float)
 * @input u_raycast.max_stepping   : the maximum allowable stepping size (float)
 * @input u_raycast.min_stepping   : the minimum allowable stepping size (float)
 *
 * @output trace.stepping          : the adjusted trace stepping size (float)
 */

// set up the coefficients for the quadratic Taylor approximation at the trace position.
vec3 taylor_coeffs = vec3(trace.error, trace.derivative, trace.derivative2 / 2.0);

// make change of variable to directly compute the next stepping and not spacing
taylor_coeffs *= vec3(1.0, ray.spacing, pow2(ray.spacing));

// solve the quadratic polynomial for the stepping value.
int num_roots; vec2 next_stepping = quadratic_roots(taylor_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(vec2(u_raycast.max_stepping), next_stepping, greaterThan(next_stepping, vec2(0.0)));
next_stepping = mix(vec2(u_raycast.max_stepping), next_stepping, bvec2(num_roots > 0));

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.stepping = mmin(next_stepping);
trace.stepping = clamp(trace.stepping, u_raycast.min_stepping, u_raycast.max_stepping);
