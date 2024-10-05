
// compute the second and third derivative using Hermitian cubic interpolation.
float slope = (trace.value - prev_trace.value) / trace.spacing;
vec2 delta = vec2(trace.derivative - slope, prev_trace.derivative - slope);

trace.derivative2 = 2.0 * (2.0 * delta.x + delta.y);
trace.derivative2 /= trace.spacing;

trace.derivative3 = 6.0 * (delta.x + delta.y);
trace.derivative3 /= pow2(trace.spacing);
