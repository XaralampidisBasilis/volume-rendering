
trace.derivative = dot(trace.gradient, ray.direction);

// compute the approximate second and third derivatives using rational[2,2] hermite interpolation with no poles.
float slope = (trace.value - prev_trace.value) / trace.spacing;
vec2 delta = vec2(trace.derivative - slope, prev_trace.derivative - slope);

trace.derivative2 = 2.0 * delta.y;
trace.derivative2 /= trace.spacing;

trace.derivative3 = - 6.0 * (delta.x + delta.y);
trace.derivative3 /= pow2(trace.spacing);
