
trace.derivative_1st = dot(trace.gradient, ray.step_direction);

// compute the approximate second and third derivatives using pade two point [1, 2] rational interpolation.
vec2 trace_speed = vec2(trace_prev.sample, trace.sample) / trace.step_distance;
float trace_slope = trace_speed.y - trace_speed.x;
vec2 teace_diff = vec2(trace.derivative_1st, trace_prev.derivative_1st) - trace_slope;
vec2 coeffs = vec2(sum(teace_diff), prod(teace_diff));
vec2 ratios = vec2(
    trace_speed.y * coeffs.x - teace_diff.y * trace_prev.derivative_1st,
    (trace_slope * coeffs.x + coeffs.y) / trace.step_distance
);
ratios /= trace_slope * trace.sample - trace_prev.derivative_1st * trace_prev.sample;

// recursive formulas
trace.derivative_2nd = 2.0 * ratios.x * trace.derivative_1st - 2.0 * ratios.y * trace.sample;
trace.derivative_3rd = 3.0 * ratios.y * trace.derivative_1st - 6.0 * ratios.x * trace.derivative_2nd;
