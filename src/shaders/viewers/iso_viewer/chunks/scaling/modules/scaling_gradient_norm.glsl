
// STEPPING_GRADIENT_NORM
/**
 * Adjusts the trace's stepping size based on the gradient norm.
 * The gradient norm is mapped to a stepping range to control the step size during raymarching.
 * 
 *
 * @input trace.gradient_magnitude      : the current gradient norm of the trace (float)
 * @input u_gradient.min_norm      : the minimum gradient norm for mapping (float)
 * @input volume.max_gradient_magnitude      : the maximum gradient norm for mapping (float)
 * @input ray.min_step_scaling   : the minimum stepping size for raymarching (float)
 * @input ray.max_step_scaling   : the maximum stepping size for raymarching (float)
 *
 * @output trace.step_scaling          : the adjusted trace stepping size (float)
 */

// map the gradient norm into the range defined by the gradient norms to get a value between 0 and 1
float mapped_gradient_norm = map(0.0, volume.max_gradient_magnitude, trace.gradient_magnitude);

// interpolate between max_stepping and min_stepping based on the mapped gradient norm.
trace.step_scaling = mix(ray.max_step_scaling, ray.min_step_scaling, mapped_gradient_norm);
