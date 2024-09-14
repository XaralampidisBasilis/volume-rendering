
// normalize trace abs error 
float trace_abs_error_norm = abs(trace.error / 0.01);

vec2 trace_abs_error_uv = vec2(mix(mean(0.5, 255.5)/256.0, 255.5/256.0, trace_abs_error_norm), 67.5/256.0); // bkr colormap right half
vec3 trace_abs_error_color = texture(u_sampler.colormap, trace_abs_error_uv).rgb;

debug.trace_abs_error = vec4(trace_abs_error_color, 1.0);
