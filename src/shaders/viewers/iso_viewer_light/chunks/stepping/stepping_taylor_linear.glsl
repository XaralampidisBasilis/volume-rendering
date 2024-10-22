
// STEPPING_TAYLOR1
/**
 * Adjusts the trace's stepping size based on the linear taylor expansion at its position.
 * The stepping size is calculated as the ratio between the trace error and the derivative,
 * normalized by the ray spacing and clamped between minimum and maximum stepping values.
 *
 * @input trace.error            : the difference between the sampled value and the threshold (float)
 * @input trace.derivative       : the current derivative of the trace (float)
 * @input ray.spacing            : the spacing size for the ray marching steps (float)
 * @input u_raycast.max_stepping : the maximum allowable stepping size (float)
 * @input u_raycast.min_stepping : the minimum allowable stepping size  (float)
 *
 * @output trace.stepping        : the adjusted trace stepping size  (float)
 */

vec2 taylor_coeffs = vec2(trace.error, trace.derivative);

// make change of variable to directly compute the next stepping and not spacing
taylor_coeffs *= vec2(1.0, ray.spacing);

// calculate the spacing size as the ratio between error and the derivative.
int num_roots; float next_stepping = linear_roots(taylor_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
next_stepping = mix(u_raycast.max_stepping, next_stepping, next_stepping > 0.0);
next_stepping = mix(u_raycast.max_stepping, next_stepping, num_roots > 0);

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.stepping = clamp(next_stepping, u_raycast.min_stepping, u_raycast.max_stepping);
