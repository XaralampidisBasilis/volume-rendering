
trace.derivative_1st = dot(trace.gradient, ray.step_direction);

// compute the approximate second and third derivatives using pade two point [2,1] rational interpolation.
float trace_slope = (trace.sample_value - trace_prev.sample_value) / trace.step_distance;
vec2 trace_diff = vec2(trace.derivative_1st, trace_prev.derivative_1st) - trace_slope;
float ratio = trace_diff.x / trace_diff.y;

trace.derivative_2nd = 2.0 * trace_diff.x * ratio;
trace.derivative_2nd /= trace.step_distance;

trace.derivative_3rd = 6.0 * (trace_diff.x + trace_diff.y) * pow2(ratio);
trace.derivative_3rd /= pow2(trace.step_distance);
