
// STEPPING_DERIVATIVE
/**
 * Adjusts the trace's stepping size based on the derivative.
 * The derivative is clamped and mapped to control how the stepping size is adjusted 
 * according to the gradient norms provided in the uniforms.
 *
 * @input trace.derivative         : the current derivative of the trace (float)
 * @input u_gradient.min_norm      : the minimum gradient norm for mapping (float)
 * @input u_gradient.max_norm      : the maximum gradient norm for mapping (float)
 * @input u_raycast.min_stepping   : the minimum stepping size for raymarching (float)
 * @input u_raycast.max_stepping   : the maximum stepping size for raymarching (float)
 *
 * @output trace.stepping          : the adjusted trace stepping size (float)
 */

// clamp the trace derivative to ensure non-negative values.
float mapped_derivative = max(trace.derivative, 0.0);

// map the derivative value into the range defined by the gradient norms to get a value between 0 and 1
mapped_derivative = map(0.0, u_gradient.max_norm, mapped_derivative);

// interpolate between max_stepping and min_stepping based on the mapped derivative.
trace.stepping = mix(u_raycast.max_stepping, u_raycast.min_stepping, mapped_derivative);