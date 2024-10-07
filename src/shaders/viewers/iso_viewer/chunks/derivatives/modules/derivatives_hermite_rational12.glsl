
trace.derivative = dot(trace.gradient, ray.direction);

// compute the approximate second and third derivatives using pade two point [1, 2] rational interpolation.
vec2 speed = vec2(prev_trace.value, trace.value) / trace.spacing;
float slope = speed.y - speed.x;
vec2 diffs = vec2(trace.derivative, prev_trace.derivative) - slope;
vec2 coeffs = vec2(sum(diffs), prod(diffs));
vec2 ratios = vec2(
    speed.y * coeffs.x - diffs.y * prev_trace.derivative,
    (slope * coeffs.x + coeffs.y) / trace.spacing
);
ratios /= slope * trace.value - prev_trace.derivative * prev_trace.value;

// recursive formulas
trace.derivative2 = 2.0 * ratios.x * trace.derivative - 2.0 * ratios.y * trace.value;
trace.derivative3 = 3.0 * ratios.y * trace.derivative - 6.0 * ratios.x * trace.derivative2;
