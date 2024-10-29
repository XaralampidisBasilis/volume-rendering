
// STEPPING_TAYLOR1
/**
 * Adjusts the trace's stepping size based on the linear taylor expansion at its position.
 * The stepping size is calculated as the ratio between the trace error and the derivative,
 * normalized by the ray spacing and clamped between minimum and maximum stepping values.
 *
 * @input trace.sample_error            : the difference between the sampled value and the threshold (float)
 * @input trace.derivative_1st       : the current derivative of the trace (float)
 * @input ray.step_distance            : the spacing size for the ray marching steps (float)
 * @input raymarch.max_step_scale : the maximum allowable stepping size (float)
 * @input raymarch.min_step_scale : the minimum allowable stepping size  (float)
 *
 * @output trace.step_scaling        : the adjusted trace stepping size  (float)
 */

vec2 taylor_coeffs = vec2(trace.sample_error, trace.derivative_1st);

// make change of variable to directly compute the next scaling and not step distance
taylor_coeffs *= vec2(1.0, ray.step_distance);

// calculate the spacing size as the ratio between error and the derivative.
int num_roots; float trace_step_scaling = linear_roots(taylor_coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
trace_step_scaling = mix(raymarch.max_step_scale, trace_step_scaling, trace_step_scaling > 0.0);
trace_step_scaling = mix(raymarch.max_step_scale, trace_step_scaling, num_roots > 0);

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.step_scaling = clamp(trace_step_scaling, raymarch.min_step_scale, raymarch.max_step_scale);
