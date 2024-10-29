
// normalize trace error
float debug_trace_error = map(-1.0, 1.0, trace.sample_error / 0.01);

vec2 debug_trace_error_uv = vec2(mix(0.5/256.0, 255.5/256.0, debug_trace_error), 67.5/256.0); // bkr colormap
vec3 debug_trace_error_color = texture(textures.colormaps, debug_trace_error_uv).rgb;

debug.trace_error = vec4(debug_trace_error_color, 1.0);
