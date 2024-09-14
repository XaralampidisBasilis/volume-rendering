
// normalize trace error
float trace_error_norm = map(-1.0, 1.0, trace.error / 0.01);

vec2 trace_error_uv = vec2(mix(0.5/256.0, 255.5/256.0, trace_error_norm), 67.5/256.0); // bkr colormap
vec3 trace_error_color = texture(u_sampler.colormap, trace_error_uv).rgb;

debug.trace_error = vec4(trace_error_color, 1.0);
