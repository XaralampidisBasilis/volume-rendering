
// STEPPING_TAYLOR2
/**
 * Uses Hermitian cubic interpolation to approximate the second derivative at the trace position 
 * and computes the quadratic Taylor approximation to solve for the stepping value.
 *
 * @input trace.sample_value              : current trace value at the ray's position (float)
 * @input trace.derivative_1st         : current derivative at the trace position (float)
 * @input trace.step_distance            : spacing between the current and previous trace (float)
 * @input trace_prev.sample_value         : previous trace value (float)
 * @input trace_prev.derivative_1st    : previous derivative at the trace position (float)
 * @input ray.step_distance              : the spacing size for ray marching steps (float)
 * @input ray.max_step_scaling   : the maximum allowable stepping size (float)
 * @input ray.min_step_scaling   : the minimum allowable stepping size (float)
 *
 * @output trace.step_scaling          : the adjusted trace stepping size (float)
 */

// set up the coefficients for the quadratic Taylor approximation at the trace position.
vec3 taylor_coeffs = vec3(trace.sample_error, trace.derivative_1st, trace.derivative_2nd / 2.0);

// make change of variable to directly compute the next stepping and not spacing
taylor_coeffs *= vec3(1.0, ray.step_distance, pow2(ray.step_distance));

// solve the quadratic polynomial for the stepping value.
int num_roots; vec2 next_stepping = quadratic_roots(taylor_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(vec2(ray.max_step_scaling), next_stepping, greaterThan(next_stepping, vec2(0.0)));
next_stepping = mix(vec2(ray.max_step_scaling), next_stepping, bvec2(num_roots > 0));

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.step_scaling = mmin(next_stepping);
trace.step_scaling = clamp(trace.step_scaling, ray.min_step_scaling, ray.max_step_scaling);
