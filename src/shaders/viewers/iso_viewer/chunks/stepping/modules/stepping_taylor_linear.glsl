
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

// calculate the spacing size as the ratio between error and the derivative.
float trace_spacing = - trace.error / maxabs(trace.derivative, EPSILON6);

// compute stepping by normalizing trace spacing with ray spacing
trace.stepping = trace_spacing / ray.spacing;

// if stepping is negative set it to max stepping 
trace.stepping = mix(u_raycast.max_stepping, trace.stepping, step(0.0, trace.stepping));

// clamp the stepping size between the minimum and maximum allowable values.
trace.stepping = clamp(trace.stepping, u_raycast.min_stepping, u_raycast.max_stepping);
