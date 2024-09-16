
// using hermitial cubic interpolation to approximate derivative2 at trace position
float slope_derivative = (trace.value - prev_trace.value) / trace.spacing;
float diff_derivative = 2.0 * trace.derivative + prev_trace.derivative - 3.0 * slope_derivative;

// compute the quadratic taylor approximation at trace position
// solving for stepping value
vec3 coeffs = vec3(
    trace.error, 
    trace.derivative * ray.spacing, 
    diff_derivative * ray.spacing / trace.stepping
);

// solve the quadratic polynomial 
float is_solvable = 1.0;
vec2 stepping_roots = quadratic_roots(coeffs, is_solvable);

// filter unwanted steppings values and set them to max stepping
// take the minimum solution and clamp the result
vec2 filter_stepping = step(0.0, stepping_roots) * is_solvable;
stepping_roots = mmix(u_raycast.max_stepping, stepping_roots, filter_stepping);
trace.stepping = mmin(stepping_roots);
trace.stepping = clamp(trace.stepping, u_raycast.min_stepping, u_raycast.max_stepping);

