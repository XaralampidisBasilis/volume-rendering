
// normalize trace abs error 
float debug_trace_sample_abs_error = abs(trace.sample_error / 0.01);
vec3 debug_trace_sample_abs_error_color = mmix(BLUE_COLOR, BLACK_COLOR, RED_COLOR, debug_trace_sample_abs_error);

// vec2 debug_trace_sample_abs_error_uv = vec2(mix(mean(0.5, 255.5)/256.0, 255.5/256.0, debug_trace_sample_abs_error), 67.5/256.0); // bkr colormap right half
// vec3 debug_trace_sample_abs_error_color = texture(u_textures.colormaps, debug_trace_sample_abs_error_uv).rgb;

debug.trace_sample_abs_error = vec4(debug_trace_sample_abs_error_color, 1.0);
