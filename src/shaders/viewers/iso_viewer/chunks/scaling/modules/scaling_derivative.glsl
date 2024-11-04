
// STEPPING_DERIVATIVE
/**
 * Adjusts the trace's stepping size based on the derivative.
 * The derivative is clamped and mapped to control how the stepping size is adjusted 
 * according to the gradient norms provided in the uniforms.
 *
 * @input trace.derivative_1st         : the current derivative of the trace (float)
 * @input u_gradient.min_norm      : the minimum gradient norm for mapping (float)
 * @input volume.max_gradient_magnitude      : the maximum gradient norm for mapping (float)
 * @input ray.min_step_scaling   : the minimum stepping size for raymarching (float)
 * @input ray.max_step_scaling   : the maximum stepping size for raymarching (float)
 *
 * @output trace.step_scaling          : the adjusted trace stepping size (float)
 */

// clamp the trace derivative to ensure non-negative values.
float derivative_scaling = max(trace.derivative_1st, 0.0);

// map the derivative value into the range defined by the gradient norms to get a value between 0 and 1
derivative_scaling = map(0.0, volume.max_gradient_magnitude, derivative_scaling);

// interpolate between max_stepping and min_stepping based on the mapped derivative.
trace.step_scaling = mix(ray.max_step_scaling, ray.min_step_scaling, derivative_scaling);