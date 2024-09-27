
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

// calculate the slope of the derivative between the current and previous trace.
float slope_derivative = (trace.value - prev_trace.value) / trace.spacing;

// compute the second derivative using Hermitian cubic interpolation.
float diff_derivative = 2.0 * trace.derivative + prev_trace.derivative - 3.0 * slope_derivative;

// set up the coefficients for the quadratic Taylor approximation at the trace position.
vec3 coeffs = vec3(
    trace.error,                          // constant term
    trace.derivative * ray.spacing,       // linear term
    diff_derivative * ray.spacing / trace.stepping // quadratic term
);

// solve the quadratic polynomial for the stepping value.
int num_roots;
vec2 stepping_roots = quadratic_roots(coeffs, num_roots);

// filter unwanted stepping values (negative or non-solvable) and set them to max stepping.
vec2 filter_stepping = step(0.0, stepping_roots) * float(num_roots > 0);
stepping_roots = mmix(u_raycast.max_stepping, stepping_roots, filter_stepping);

// choose the minimum valid solution and clamp the result between the allowable stepping range.
trace.stepping = mmin(stepping_roots);
trace.stepping = clamp(trace.stepping, u_raycast.min_stepping, u_raycast.max_stepping);
