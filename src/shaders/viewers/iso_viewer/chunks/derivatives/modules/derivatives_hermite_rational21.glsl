
trace.derivative = dot(trace.gradient, ray.direction);

// compute the approximate second and third derivatives using pade two point [2,1] rational interpolation.
float slope = (trace.value - prev_trace.value) / trace.spacing;
vec2 delta = vec2(trace.derivative - slope, prev_trace.derivative - slope);
float ratio = delta.x / delta.y;

trace.derivative2 = 2.0 * delta.x * ratio;
trace.derivative2 /= trace.spacing;

trace.derivative3 = 6.0 * (delta.x + delta.y) * pow2(ratio);
trace.derivative3 /= pow2(trace.spacing);
