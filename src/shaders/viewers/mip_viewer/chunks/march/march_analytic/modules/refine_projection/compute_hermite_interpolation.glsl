
// select intervals based on gradient direction
vec2 s = vec2(0.0, 1.0);
vec2 t = vec2(trace_prev.distance,     trace_next.distance);
vec2 f = vec2(trace_prev.sample_value, trace_next.sample_value);
vec2 d = vec2(trace_prev.derivative,   trace_next.derivative);
d *= t.y - t.x;

vec4 coeffs = hermite_cubic_coefficients(s, f, d);   // compute cubic hermite coefficients
coeffs *= vec4(0.0, 1.0, 2.0, 3.0);                  // compute derivative hermite coefficients

vec2 s_roots = quadratic_roots(coeffs.yzw);          // compute the roots of the equation H(t)' = 0
s_roots = clamp(s_roots, s.xx, s.yy);                // clamp normalized roots to the interval

vec2 t_roots = mix(t.xx, t.yy, s_roots);             // denormalize roots
