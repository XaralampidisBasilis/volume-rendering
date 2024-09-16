
// STEPPING_GRADIENT_NORM
/**
 * Adjusts the trace's stepping size based on the gradient norm.
 * The gradient norm is mapped to a stepping range to control the step size during raymarching.
 * 
 *
 * @input trace.gradient_norm      : the current gradient norm of the trace (float)
 * @input u_gradient.min_norm      : the minimum gradient norm for mapping (float)
 * @input u_gradient.max_norm      : the maximum gradient norm for mapping (float)
 * @input u_raycast.min_stepping   : the minimum stepping size for raymarching (float)
 * @input u_raycast.max_stepping   : the maximum stepping size for raymarching (float)
 *
 * @output trace.stepping          : the adjusted trace stepping size (float)
 */

// map the gradient norm into the range defined by the gradient norms to get a value between 0 and 1
float mapped_gradient_norm = map(u_gradient.min_norm, u_gradient.max_norm, trace.gradient_norm);

// interpolate between max_stepping and min_stepping based on the mapped gradient norm.
trace.stepping = mix(u_raycast.max_stepping, u_raycast.min_stepping, mapped_gradient_norm);
