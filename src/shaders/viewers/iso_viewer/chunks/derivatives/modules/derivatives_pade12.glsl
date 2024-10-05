
// compute theapproximate second and third derivatives using pade two point [2,1] rational interpolation.
float dx = trace.spacing;
float f = vec2(trace.value, prev_trace.value);
float g = vec2(trace.derivative, prev_trace.derivative);
float slope = (f.y - f.x) / dx;
vec2 delta = g - slope;
vec2 mixed = vec2(slope^3 - g.y * g.x^2, slope * f.y - g.y * g.x);

trace.derivative2 = 2.0 * (f.y * delta.x^2 + dx * mixed.y);
trace.derivative2 /= dx * mixed.y;

trace.derivative3 = 6.0 * (delta.x + delta.y) * pow2(ratio);
trace.derivative3 /= pow2(dx * mixed.y);
