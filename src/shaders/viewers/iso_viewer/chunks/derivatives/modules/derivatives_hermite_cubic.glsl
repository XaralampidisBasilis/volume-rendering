
trace.derivative_1st = dot(trace.gradient, ray.step_direction);

// compute the approximate second and third derivatives using Hermitian cubic interpolation.
float trace_slope = (trace.sample_value - trace_prev.sample_value) / trace.step_distance;
vec2 trace_diff = vec2(trace.derivative_1st, trace_prev.derivative_1st) - trace_slope;

trace.derivative_2nd = 2.0 * (2.0 * trace_diff.x + trace_diff.y);
trace.derivative_2nd /= trace.step_distance;

trace.derivative_3rd = 6.0 * (trace_diff.x + trace_diff.y);
trace.derivative_3rd /= pow2(trace.step_distance);
